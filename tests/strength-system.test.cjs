// Run with: node tests/strength-system.test.cjs
// Executes the numeric ActionScript and selected engine methods after removing
// type annotations. This is a regression check, not an AS3 compiler or game test.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const engine = path.join(__dirname, '..', 'src', 'Super Smash Flash 2 Beta v1.3.1.1',
    'com', 'mcleodgaming', 'ssf2', 'engine');
const strengthSource = fs.readFileSync(path.join(engine, 'StrengthSystem.as'), 'utf8');
const characterSource = fs.readFileSync(path.join(engine, 'Character.as'), 'utf8');
const spriteSource = fs.readFileSync(path.join(engine, 'InteractiveSprite.as'), 'utf8');

function bodyAt(source, opening) {
    let depth = 0;
    let quote = null;
    let lineComment = false;
    let blockComment = false;
    for (let i = opening; i < source.length; i++) {
        const c = source[i], next = source[i + 1];
        if (lineComment) { if (c === '\n') lineComment = false; continue; }
        if (blockComment) { if (c === '*' && next === '/') { blockComment = false; i++; } continue; }
        if (quote) { if (c === '\\') { i++; continue; } if (c === quote) quote = null; continue; }
        if (c === '/' && next === '/') { lineComment = true; i++; continue; }
        if (c === '/' && next === '*') { blockComment = true; i++; continue; }
        if (c === '"' || c === "'") { quote = c; continue; }
        if (c === '{') depth++;
        if (c === '}' && --depth === 0) return source.slice(opening + 1, i);
    }
    throw new Error('Unclosed method/class');
}

function method(source, name) {
    const match = new RegExp('function ' + name + '\\(([^)]*)\\)[^{]*\\{').exec(source);
    assert.ok(match, name);
    const opening = match.index + match[0].length - 1;
    return { parameters: match[1], body: bodyAt(source, opening) };
}

function eraseTypes(code) {
    return code.replace(/:(?:Number|Boolean|int|uint|void|String|Character|Point|InteractiveSprite|InteractiveSpriteStats|AttackDamage)\b/g, '')
        .replace(/:\*/g, '')
        .replace(/\bint\(/g, 'Math.trunc(')
        .replace(/\b(Character|Projectile)\(/g, 'cast$1(')
        .replace(/([\w.]+) is (Character|Projectile)/g, '$1 instanceof $2');
}

function loadStrength(enabled = true) {
    const opening = strengthSource.indexOf('{', strengthSource.indexOf('public final class'));
    let code = bodyAt(strengthSource, opening);
    if (!enabled) code = code.replace('ENABLED:Boolean = true', 'ENABLED:Boolean = false');
    const names = [...code.matchAll(/public static (?:const|function) (\w+)/g)].map(m => m[1]);
    code = code.replace(/(?:public|private) static const/g, 'const')
        .replace(/(?:public|private) static function/g, 'function');
    const context = { isFinite };
    vm.createContext(context);
    vm.runInContext(eraseTypes(code) + '\nglobalThis.api = {' + names.join(',') + '};', context);
    return context.api;
}

const S = loadStrength();
let checks = 0;
function test(name, run) { run(); checks++; console.log('PASS ' + name); }
function near(actual, expected) { assert.ok(Math.abs(actual - expected) < 1e-10, actual + ' != ' + expected); }

test('Neutral and proportional strength, with bad-stat fallbacks', () => {
    near(S.getScore(100, 40), 1);
    near(S.getScore(120, 60), 1.8);
    near(S.getScore(60, 20), 0.3);
    near(S.getScore(NaN, 0), 1);
    near(S.getScore(Infinity, -1), 1);
    near(S.getStrength(null), 1);
    near(S.getStrength({ Weight1: 120, Height: 60 }), 1.8);
    assert.equal(S.getScore(1e-9, 1e-9), 0.02);
    assert.equal(S.getScore(1e6, 1e6), 100);
});

test('Grab failure and no-escape boundaries are exact', () => {
    assert.equal(S.canGrab(0.60), false);
    assert.equal(S.canGrab(0.600001), true);
    assert.equal(S.isGrabLocked(1.699999), false);
    assert.equal(S.isGrabLocked(1.70), true);
    near(S.getGrabDurationMultiplier(1, 1), 1);
    near(S.getGrabDurationMultiplier(1.25, 1), Math.exp(0.8));
    assert.ok(S.getGrabDurationMultiplier(1, 0.3) > S.getGrabDurationMultiplier(1, 1));
    assert.equal(S.getGrabDurationMultiplier(1.69, 0.02), S.MAX_GRAB_DURATION);
});

test('Reverse mismatches produce opposite damage, reach, pummel and throw effects', () => {
    const weak = S.getScore(60, 20), strong = S.getScore(120, 60);
    const ratio = S.getMatchupRatio(strong, weak);
    near(S.getMatchupRatio(weak, strong), 1 / ratio);
    assert.equal(S.canGrab(1 / ratio), false);
    assert.equal(S.isGrabLocked(ratio), true);
    assert.ok(S.getDamageDealtMultiplier(strong) > 1);
    assert.ok(S.getDamageDealtMultiplier(weak) < 1);
    assert.ok(S.getDamageTakenMultiplier(strong) < 1);
    assert.ok(S.getDamageTakenMultiplier(weak) > 1);
    assert.ok(S.getGrabReachMultiplier(strong) > 1);
    assert.ok(S.getGrabReachMultiplier(weak) < 1);
    assert.ok(S.getPummelMultiplier(ratio) > 1);
    assert.ok(S.getPummelMultiplier(1 / ratio) < 1);
    assert.ok(S.getThrowMultiplier(ratio) > 1);
    assert.ok(S.getThrowMultiplier(1 / ratio) < 1);
});

test('Finite modifiers and monotonic curves across the supported strength range', () => {
    const scores = [0.02, 0.1, 0.3, 0.65, 1, 1.25, 1.7, 3, 10, 100];
    const increasing = ['getDamageDealtMultiplier', 'getGrabReachMultiplier', 'getArmorThreshold', 'getPummelMultiplier', 'getThrowMultiplier'];
    const decreasing = ['getDamageTakenMultiplier', 'getHitstunMultiplier'];
    for (const name of [...increasing, ...decreasing]) {
        const values = scores.map(S[name]);
        values.forEach(v => assert.ok(Number.isFinite(v)));
        for (let i = 1; i < values.length; i++) {
            assert.ok(increasing.includes(name) ? values[i] >= values[i - 1] : values[i] <= values[i - 1], name);
        }
    }
    assert.equal(S.getPummelMultiplier(5000), 5);
    assert.equal(S.getPummelMultiplier(0.0002), 0.2);
    assert.equal(S.getThrowMultiplier(5000), 4);
    assert.equal(S.getThrowMultiplier(0.0002), 0.25);
    assert.equal(S.getArmorThreshold(100), 6);
});

test('Hitstun retains zero/sentinels and armor starts only above its cutoff', () => {
    assert.equal(S.scaleHitstun(0, 0.02), 0);
    assert.equal(S.scaleHitstun(-1, 100), -1);
    assert.equal(S.scaleHitstun(10, 0.02), 16);
    assert.equal(S.scaleHitstun(10, 100), 6);
    assert.equal(S.scaleHitstun(1, 100), 1);
    assert.equal(S.getArmorThreshold(1.25), 0);
    assert.ok(S.getArmorThreshold(1.2501) > 0);
});

const CState = { GRABBING: 1, CAUGHT: 2, IDLE: 3 };
const HitBoxSprite = { GRAB: 2, MASTER: 24, HIT: 1 };
class Point {
    constructor(x, y) { this.x = x; this.y = y; }
    clone() { return new Point(this.x, this.y); }
}
class Character {
    constructor(weight = 100, height = 40) {
        this.m_characterStats = { Weight1: weight, Height: height, Stamina: 0 };
        this.m_grabbed = [];
        this.m_internalGrabLock = false;
        this.m_strengthGrabLocked = false;
        this.m_justPummeled = false;
        this.CurrentScale = new Point(2, 3);
        this.state = CState.IDLE;
    }
    inState(state) { return this.state === state; }
    setState(state) { this.state = state; }
    Caught() { return this.inState(CState.CAUGHT); }
    get CharacterStats() { return this.m_characterStats; }
    getDamage() { return 0; }
    Uncapture() { this.state = CState.IDLE; }
    setVisibility() {}
    forceEndAttack() {}
    stancePlayFrame() {}
    checkLinkedProjectiles() {}
}
class Projectile {
    constructor(owner, reversed = false) { this.owner = owner; this.WasReversed = reversed; }
    getOwner() { return this.owner; }
}
const context = { StrengthSystem: S, CState, HitBoxSprite, Character, Projectile,
    castCharacter: value => value, castProjectile: value => value,
    Utils: { calculatePummelTime: x => Math.trunc(x / 13 * 3), calculateGrabLength: x => Math.trunc((90 + x * 1.7) / 2), getUID: () => 1 } };
vm.createContext(context);
function compileBody(parameters, body) {
    return vm.runInContext('(function(' + eraseTypes(parameters) + ') { with(this) {' + eraseTypes(body) + '} })', context);
}
for (const name of ['getStrengthScore', 'getStrengthCollisionScale', 'getStrengthGrabRatio', 'initializeStrengthGrab',
    'isStrengthPummel', 'getStrengthAttacker', 'releaseOpponent', 'removeUngrabbedCharacters', 'toGrabbing']) {
    const m = method(characterSource, name);
    Character.prototype[name] = compileBody(m.parameters, m.body);
}

test('Both grab setups snapshot lock and preserve vanilla pummel timing', () => {
    const strong = new Character(120, 60), weak = new Character(60, 20);
    strong.initializeStrengthGrab(weak, 100);
    assert.equal(strong.m_strengthGrabLocked, true);
    assert.equal(strong.m_grabTimer, 100);
    assert.equal(strong.m_pummelTimer, Math.trunc(100 / 13 * 3));
    strong.initializeStrengthGrab(new Character(120, 60), 100);
    assert.equal(strong.m_strengthGrabLocked, false);
    assert.equal(strong.m_grabTimer, 100);
    const converted = new Character(120, 60);
    converted.m_grabbed = [weak];
    converted.m_attack = {};
    converted.toGrabbing();
    assert.equal(converted.state, CState.GRABBING);
    assert.equal(converted.m_strengthGrabLocked, true);
});

test('Grab reach does not mutate scales or shrink broad-phase bounds', () => {
    const strong = new Character(120, 60), weak = new Character(60, 20);
    strong.state = weak.state = CState.GRABBING;
    const first = strong.getStrengthCollisionScale(HitBoxSprite.GRAB);
    const second = strong.getStrengthCollisionScale(HitBoxSprite.GRAB);
    near(first.x, 2 * S.getGrabReachMultiplier(1.8));
    near(second.x, first.x);
    assert.equal(first.y, 3);
    assert.equal(strong.CurrentScale.x, 2);
    assert.equal(strong.getStrengthCollisionScale(HitBoxSprite.MASTER).x, first.x);
    assert.equal(weak.getStrengthCollisionScale(HitBoxSprite.MASTER).x, 2);
    assert.equal(strong.getStrengthCollisionScale(HitBoxSprite.HIT).x, 2);
    strong.state = CState.IDLE;
    assert.equal(strong.getStrengthCollisionScale(HitBoxSprite.GRAB).x, 2);
});

test('Direct, nested and reflected projectiles use the right attacker', () => {
    const victim = new Character(), original = new Character(), reflector = new Character();
    victim.STAGEDATA = { getPlayerByID: id => id === 2 ? reflector : null };
    assert.equal(victim.getStrengthAttacker({ Owner: original }), original);
    assert.equal(victim.getStrengthAttacker({ Owner: new Projectile(new Projectile(original)) }), original);
    assert.equal(victim.getStrengthAttacker({ Owner: new Projectile(original, true), PlayerID: 2 }), reflector);
    assert.equal(victim.getStrengthAttacker({ Owner: new Projectile(original, true), PlayerID: -1 }), null);
    assert.equal(victim.getStrengthAttacker({ Owner: null }), null);
    assert.equal(victim.getStrengthAttacker({ Owner: {} }), null);
    const cyclic = new Projectile(null); cyclic.owner = cyclic;
    assert.equal(victim.getStrengthAttacker({ Owner: cyclic }), null);
});

test('Pummel classification requires the held victim and active normal pummel', () => {
    const grabber = new Character(), victim = new Character();
    grabber.state = CState.GRABBING; victim.state = CState.CAUGHT;
    grabber.m_justPummeled = true; grabber.m_grabbed = [victim];
    assert.equal(grabber.isStrengthPummel(victim), true);
    assert.equal(grabber.isStrengthPummel(new Character()), false);
    grabber.m_justPummeled = false;
    assert.equal(grabber.isStrengthPummel(victim), false);
    grabber.m_justPummeled = true; grabber.state = CState.IDLE;
    assert.equal(grabber.isStrengthPummel(victim), false);
});

test('Actual timer/mash hooks freeze a locked hold and let an unlocked hold expire', () => {
    const grab = method(characterSource, 'm_charGrab').body;
    const decay = /if \(!this.m_strengthGrabLocked\)\s*\{\s*this.m_grabTimer--;\s*\}/.exec(grab);
    const mash = /if \(!this.m_strengthGrabLocked\)\s*\{\s*loss = this.m_grabbed\[i\].Struggle\(\);\s*this.m_grabTimer =[^;]+;\s*\}/.exec(grab);
    assert.ok(decay); assert.ok(mash);
    const tick = compileBody('', 'var i:int = 0; var loss:int; ' + decay[0] + mash[0]);
    const g = new Character(); g.m_grabTimer = 100; g.m_strengthGrabLocked = true;
    g.m_grabbed = [{ Struggle: () => 4 }];
    for (let i = 0; i < 500; i++) tick.call(g);
    assert.equal(g.m_grabTimer, 100);
    g.m_strengthGrabLocked = false;
    for (let i = 0; i < 20; i++) tick.call(g);
    assert.equal(g.m_grabTimer, 0);
});

test('Releases, external uncaptures and internal grab locks clear or retain state correctly', () => {
    const g = new Character(), victim = new Character();
    g.state = CState.GRABBING; victim.state = CState.CAUGHT;
    g.m_grabbed = [victim]; g.m_strengthGrabLocked = true;
    g.m_internalGrabLock = true; g.releaseOpponent();
    assert.equal(g.m_strengthGrabLocked, true);
    g.m_internalGrabLock = false; g.releaseOpponent();
    assert.equal(g.m_strengthGrabLocked, false);
    assert.equal(g.m_grabbed.length, 0);
    assert.equal(g.state, CState.IDLE);
    assert.equal(victim.state, CState.IDLE);
    g.m_strengthGrabLocked = true; g.m_grabbed = [{ State: CState.IDLE }];
    g.removeUngrabbedCharacters();
    assert.equal(g.m_strengthGrabLocked, false);
});

test('Combat hooks classify pummels before capture changes and scale both damage branches', () => {
    const damage = method(characterSource, 'takeDamage').body;
    assert.ok(damage.indexOf('strengthAttacker.isStrengthPummel(this)') < damage.indexOf('this.Uncapture()'));
    assert.equal((damage.match(/tempDamage \*= strengthDamageMultiplier;/g) || []).length, 2);
    assert.ok(damage.includes('tempKnockback *= strengthThrowMultiplier;'));
    assert.ok(damage.includes('tempVelocity *= strengthThrowMultiplier;'));
    assert.equal((damage.match(/startActionShot\(StrengthSystem.scaleHitstun/g) || []).length, 3);
    const grab = method(characterSource, 'reactionGrab').body;
    assert.ok(grab.indexOf('StrengthSystem.canGrab') < grab.indexOf('opponent.Capture'));
    assert.equal((characterSource.match(/this.initializeStrengthGrab\(/g) || []).length, 2);
    const collision = method(spriteSource, 'hitTest').body;
    assert.ok(collision.includes('getStrengthCollisionScale(myType)'));
    assert.equal((collision.match(/myScale, theirScale/g) || []).length, 2);
});

test('Combat snapshots stack modest damage with severe pummels and isolate throw launch scaling', () => {
    const damage = method(characterSource, 'takeDamage').body;
    const start = damage.indexOf('var strengthAttacker:Character');
    const end = damage.indexOf('\n            preDamage =', start);
    const snapshot = compileBody('attackObj', damage.slice(start, end) +
        '\nreturn { damage: strengthDamageMultiplier, launch: strengthThrowMultiplier, stun: strengthHitstun };');
    const grabber = new Character(120, 60), victim = new Character(60, 20);
    grabber.state = CState.GRABBING; victim.state = CState.CAUGHT;
    grabber.m_grabbed = [victim]; grabber.m_justPummeled = true;
    const ordinary = snapshot.call(victim, { Owner: new Projectile(grabber), Damage: 10, IsThrow: false });
    const pummel = snapshot.call(victim, { Owner: grabber, Damage: 2, IsThrow: false });
    const thrown = snapshot.call(victim, { Owner: grabber, Damage: 10, IsThrow: true });
    near(ordinary.damage, S.getDamageDealtMultiplier(1.8) * S.getDamageTakenMultiplier(0.3));
    near(pummel.damage, ordinary.damage * S.getPummelMultiplier(6));
    near(thrown.damage, ordinary.damage);
    near(thrown.launch, S.getThrowMultiplier(6));
    assert.equal(ordinary.launch, 1);
    assert.equal(pummel.launch, 1);
    assert.equal(pummel.stun, victim.getStrengthScore());
    victim.Uncapture(); grabber.m_grabbed = [];
    near(pummel.damage, ordinary.damage * S.getPummelMultiplier(6));
    const release = snapshot.call(victim, { Owner: victim, Damage: 0, IsThrow: false });
    assert.equal(release.damage, 1);
    assert.equal(release.stun, 1);
});

test('Command-to-normal conversion rejects an impossible hold before conversion', () => {
    const weak = new Character(60, 20), strong = new Character(120, 60);
    weak.m_grabbed = [strong];
    let released = false, recoil = false;
    weak.grabReleaseOpponent = () => { released = true; weak.m_grabbed = []; };
    weak.grabRelease = () => { recoil = true; };
    weak.forceEndAttack = () => { throw new Error('Invalid hold must not convert'); };
    weak.toGrabbing();
    assert.equal(released, true);
    assert.equal(recoil, true);
});

test('Passive armor respects throw/bypass/capture rules and incoming modified damage', () => {
    const damage = method(characterSource, 'takeDamage').body;
    const start = damage.indexOf('var strengthArmorThreshold');
    const end = damage.indexOf('\n            if (strengthArmored', start);
    assert.ok(start >= 0 && end > start);
    const conditionEnd = damage.indexOf('\n            {', end);
    new vm.Script(damage.slice(end, conditionEnd) + ' {}');
    const check = compileBody('attackObj, victimStrength, preDamage, strengthDamageMultiplier',
        damage.slice(start, end) + '\nreturn strengthArmored;');
    const victim = new Character();
    const hit = { IsThrow: false, BypassHeavyArmor: false, StaleMultiplier: 1 };
    assert.equal(check.call(victim, hit, 2, 1, 1), true);
    assert.equal(check.call(victim, hit, 2, 10, 1), false);
    assert.equal(check.call(victim, { ...hit, IsThrow: true }, 2, 1, 1), false);
    assert.equal(check.call(victim, { ...hit, BypassHeavyArmor: true }, 2, 1, 1), false);
    victim.state = CState.CAUGHT;
    assert.equal(check.call(victim, hit, 2, 1, 1), false);
});

test('Disabling the subsystem returns vanilla modifiers and escape behavior', () => {
    const off = loadStrength(false);
    assert.equal(off.getScore(120, 60), 1);
    assert.equal(off.canGrab(0.1), true);
    assert.equal(off.isGrabLocked(100), false);
    assert.equal(off.getGrabDurationMultiplier(1.69, 0.02), 1);
    for (const name of ['getDamageDealtMultiplier', 'getDamageTakenMultiplier', 'getHitstunMultiplier',
        'getGrabReachMultiplier', 'getPummelMultiplier', 'getThrowMultiplier']) assert.equal(off[name](100), 1);
    assert.equal(off.getArmorThreshold(100), 0);
    assert.equal(off.scaleHitstun(10, 100), 10);
});

console.log(checks + ' strength regression checks passed. Animate/AIR build and gameplay testing still required.');
