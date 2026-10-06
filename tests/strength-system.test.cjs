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
const dkStats = JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures', 'dk-cargo-stats.json'), 'utf8'));
const projectileSource = fs.readFileSync(path.join(engine, 'Projectile.as'), 'utf8');

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
    return code.replace(/:(?:Number|Boolean|int|uint|void|String|Object|Function|MovieClip|FrameTimer|HitBoxSprite|Character|Point|InteractiveSprite|InteractiveSpriteStats|AttackDamage)\b/g, '')
        .replace(/:\*/g, '')
        .replace(/\bint\(/g, 'Math.trunc(')
        .replace(/\b(Character|Projectile)\(/g, 'cast$1(')
        .replace(/\bis (Character|Projectile|Enemy)\b/g, 'instanceof $1');
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
    assert.equal(S.getArmorThreshold(100), 30);
});

test('Hitstun retains zero/sentinels and armor starts only above its cutoff', () => {
    assert.equal(S.scaleHitstun(0, 0.02), 0);
    assert.equal(S.scaleHitstun(-1, 100), -1);
    assert.equal(S.scaleHitstun(10, 0.02), 16);
    assert.equal(S.scaleHitstun(10, 100), 6);
    assert.equal(S.scaleHitstun(1, 100), 1);
    assert.equal(S.getArmorThreshold(1.0), 0);
    assert.ok(S.getArmorThreshold(1.0001) > 0);
});

const CState = { GRABBING: 1, CAUGHT: 2, IDLE: 3, DIZZY: 4, ATTACKING: 5, TUMBLE_FALL: 6, CRASH_LAND: 7, FROZEN: 8, STAMINA_KO: 9, DEAD: 10, BARREL: 11, EGG: 12 };
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
        this.m_strengthDizzyTimer = 0;
        this.m_justPummeled = false;
        this.CurrentScale = new Point(2, 3);
        this.state = CState.IDLE;
    }
    inState(state) { return this.state === state; }
    setState(state) { this.state = state; }
    isIntangible() { return false; }
    isInvincible() { return false; }
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
    constructor(owner, reversed = false) {
        this.owner = owner; this.WasReversed = reversed; this.m_wasReversed = reversed;
        this.m_strengthNormalAttack = false;
    }
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
    'isStrengthPummel', 'getStrengthDizzy', 'applyStrengthDizzy', 'm_checkDizzy', 'checkFrameControl', 'killAllSpeeds', 'getStrengthAttacker', 'releaseOpponent', 'removeUngrabbedCharacters', 'toGrabbing']) {
    const m = method(characterSource, name);
    Character.prototype[name] = compileBody(m.parameters, m.body);
}
const stateBody = method(characterSource, 'setState').body;
const cleanupStart = stateBody.indexOf('if (state != CState.DIZZY)');
assert.ok(cleanupStart >= 0);
const cleanupOpening = stateBody.indexOf('{', cleanupStart);
const cleanupDizzy = compileBody('state', stateBody.slice(cleanupStart, cleanupOpening) +
    '{' + bodyAt(stateBody, cleanupOpening) + '}');
Character.prototype.setState = function(state) {
    this.state = this.m_state = state;
    cleanupDizzy.call(this, state);
};
const projectileOrigin = method(projectileSource, 'isStrengthNormalAttackSource');
Projectile.prototype.isStrengthNormalAttackSource = compileBody(projectileOrigin.parameters, projectileOrigin.body);
const originGetter = /function get StrengthNormalAttack\(\)[^{]*\{/.exec(projectileSource);
assert.ok(originGetter);
Object.defineProperty(Projectile.prototype, 'StrengthNormalAttack', {
    get: compileBody('', bodyAt(projectileSource, originGetter.index + originGetter[0].length - 1))
});

// Exercise the stock timer implementation alongside DK's packaged callback.
function loadTimerClass(name) {
    const source = fs.readFileSync(path.join(engine, '..', 'util', name + '.as'), 'utf8');
    const opening = source.indexOf('{', source.indexOf('public class'));
    let code = bodyAt(source, opening)
        .replace(/private var /g, '')
        .replace(new RegExp('public function ' + name + '\\('), 'constructor(')
        .replace(/public function (get|set) /g, '$1 ')
        .replace(/(?:public|private) function /g, '');
    vm.runInContext('globalThis.' + name + ' = class ' + name + ' {' + eraseTypes(code) + '};', context);
    return context[name];
}
loadTimerClass('FrameTimer');
const IntervalTimer = loadTimerClass('IntervalTimer');
const baseCreateTimer = method(spriteSource, 'createTimer');
Character.prototype.baseCreateTimer = compileBody(baseCreateTimer.parameters, baseCreateTimer.body);
const cargoCreateTimer = method(characterSource, 'createTimer');
Character.prototype.createTimer = compileBody(cargoCreateTimer.parameters,
    cargoCreateTimer.body.replace('super.createTimer(', 'this.baseCreateTimer('));

test('Actual DK cargo escape timer scales, freezes natural/mash escape, and retains callback identity', () => {
    const fixture = fs.readFileSync(path.join(__dirname, 'fixtures', 'dk-cargo-escape.as'), 'utf8');
    const escape = method(fixture, 'getFree');
    const getFree = compileBody(escape.parameters, escape.body);
    function setup(holder, victim, options = null) {
        holder.m_characterStats.LinkageID = dkStats.linkage_id;
        holder.m_characterStats.StatsName = dkStats.statsName;
        holder.m_attack = { Frame: 'throw_forward' };
        holder.m_grabbed = [victim];
        holder.m_timers = [];
        holder.timerHitStunPauseCallback = () => holder.m_actionShot;
        const controls = { UP: true };
        const clip = { endTimer: 100, mashInfluence: 2, formerControl: null,
            theOpponent: { getControls: () => controls }, self: {
                destroyTimer: callback => { holder.m_timers = holder.m_timers.filter(t => t.Callback !== callback); },
                stancePlayFrame: frame => { clip.escaped = frame === 'end'; }
            } };
        clip.getFree = getFree.bind(clip);
        holder.Stance = clip;
        holder.createTimer(1, 0, clip.getFree, options);
        const timer = holder.m_timers[0];
        assert.ok(timer instanceof IntervalTimer);
        assert.equal(timer.Callback, clip.getFree);
        return { holder, clip, timer, controls };
    }
    function tick(x, frames) {
        for (let i = 0; i < frames; i++) {
            x.controls.UP = i % 2 === 0; x.controls.DOWN = !x.controls.UP;
            x.timer.tick(); x.timer.process();
        }
    }
    const options = { hitStunPause: true, persistent: false };
    const locked = setup(new Character(114, 75), new Character(74, 30), options);
    tick(locked, 1000);
    assert.equal(locked.clip.endTimer, 100);
    assert.equal(locked.clip.escaped, undefined);
    assert.equal(locked.clip.formerControl, null);
    assert.deepEqual(options, { hitStunPause: true, persistent: false });
    // Throw/startup timers still run; the original callback can still be destroyed.
    let throws = 0;
    locked.holder.createTimer(1, 1, () => throws++);
    locked.holder.m_timers[1].tick(); locked.holder.m_timers[1].process();
    assert.equal(throws, 1);
    locked.clip.self.destroyTimer(locked.clip.getFree);
    assert.equal(locked.holder.m_timers.some(t => t.Callback === locked.clip.getFree), false);
    const equal = setup(new Character(114, 75), new Character(114, 75));
    assert.equal(equal.clip.endTimer, 100);
    tick(equal, 1); assert.equal(equal.clip.endTimer, 97);
    tick(equal, 34); assert.equal(equal.clip.escaped, true);
    const finite = setup(new Character(114, 75), new Character(120, 64));
    const ratio = finite.holder.getStrengthGrabRatio(finite.holder.m_grabbed[0]);
    assert.equal(finite.clip.endTimer, Math.round(100 * S.getGrabDurationMultiplier(ratio, 1.92)));
    assert.ok(finite.clip.endTimer > 100);
    tick(finite, 100); assert.equal(finite.clip.escaped, true);
    context.StrengthSystem = loadStrength(false);
    try {
        const off = setup(new Character(114, 75), new Character(74, 30));
        assert.equal(off.clip.endTimer, 100);
        tick(off, 35); assert.equal(off.clip.escaped, true);
    } finally { context.StrengthSystem = S; }
    // Other character scripts and other DK callbacks receive no cargo modifier.
    const unrelated = new Character(114, 75);
    unrelated.Stance = { endTimer: 100, getFree() {} }; unrelated.m_attack = { Frame: 'b' };
    unrelated.m_characterStats.LinkageID = dkStats.linkage_id;
    unrelated.m_characterStats.StatsName = dkStats.statsName; unrelated.m_timers = [];
    unrelated.createTimer(1, 0, unrelated.Stance.getFree);
    assert.equal(unrelated.Stance.endTimer, 100);
});

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
    const ordinary = snapshot.call(victim, { Owner: new Projectile(grabber), Damage: 10, Dizzy: 0, IsThrow: false });
    const pummel = snapshot.call(victim, { Owner: grabber, Damage: 2, Dizzy: 0, IsThrow: false });
    const thrown = snapshot.call(victim, { Owner: grabber, Damage: 10, Dizzy: 0, IsThrow: true });
    near(ordinary.damage, S.getDamageDealtMultiplier(1.8) * S.getDamageTakenMultiplier(0.3));
    near(pummel.damage, ordinary.damage * S.getPummelMultiplier(6));
    near(thrown.damage, ordinary.damage);
    near(thrown.launch, S.getThrowMultiplier(6));
    assert.equal(ordinary.launch, 1);
    assert.equal(pummel.launch, 1);
    assert.equal(pummel.stun, victim.getStrengthScore());
    victim.Uncapture(); grabber.m_grabbed = [];
    near(pummel.damage, ordinary.damage * S.getPummelMultiplier(6));
    const release = snapshot.call(victim, { Owner: victim, Damage: 0, Dizzy: 0, IsThrow: false });
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
    const check = compileBody('attackObj, victimStrength, preDamage, strengthDamageMultiplier, strengthMatchupArmored=false',
        damage.slice(start, end) + '\nreturn strengthArmored;');
    const victim = new Character();
    const hit = { IsThrow: false, BypassHeavyArmor: false, StaleMultiplier: 1 };
    assert.equal(check.call(victim, hit, 2, 1, 1), true);
    assert.equal(check.call(victim, hit, 2, 15, 1), false);
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
    assert.equal(off.hasMatchupArmor(0.01), false);
    assert.equal(off.getWeakAttackDamageMultiplier(0.01), 1);
    assert.equal(off.getDizzyDuration(100), 0);
    assert.equal(off.scaleHitstun(10, 100), 10);
});

test('Matchup armor and weak damage have exact boundaries and reverse cleanly', () => {
    assert.equal(S.hasMatchupArmor(1 / 1.70), true);
    assert.equal(S.hasMatchupArmor(1 / 1.699999), false);
    assert.equal(S.hasMatchupArmor(1.7), false);
    assert.equal(S.hasMatchupArmor(0), false);
    assert.equal(S.getWeakAttackDamageMultiplier(1), 1);
    assert.equal(S.getWeakAttackDamageMultiplier(10), 1);
    assert.equal(S.getWeakAttackDamageMultiplier(0.001), 0.03);
    assert.ok(S.getWeakAttackDamageMultiplier(1 / 1.7) <= 0.10);
    const ratios = [0.001, 0.1, 0.3, 1 / 1.7, 0.6, 0.9, 1, 10];
    const values = ratios.map(S.getWeakAttackDamageMultiplier);
    for (let i = 1; i < values.length; i++) assert.ok(values[i] >= values[i - 1]);
});

test('Packaged Pichu/Bowser stats produce tiny damage and no hitstun/launch in the actual damage method', () => {
    const take = method(characterSource, 'takeDamage');
    const actualTakeDamage = compileBody(take.parameters, take.body);
    const pichu = new Character(74, 30), bowser = new Character(120, 64);
    near(pichu.getStrengthScore(), 0.555); near(bowser.getStrengthScore(), 1.92);
    assert.equal(S.canGrab(pichu.getStrengthGrabRatio(bowser)), false);
    Object.assign(context.Utils, {
        calculateSpeed: () => 0, calculateChargeDamage: a => a.Damage,
        calculateVelocity: n => n, calculateKnockback: () => 100, rotateAroundCenter() {}
    });
    context.SpecialMode = { modeEnabled: () => false };
    context.MenuController = { debugConsole: null };
    context.SSF2Event = function () {};
    const damageFactor = S.getDamageDealtMultiplier(0.555) * S.getDamageTakenMultiplier(1.92) *
        S.getWeakAttackDamageMultiplier(0.555 / 1.92);
    assert.ok(damageFactor > 0 && damageFactor < 0.03);
    // Run the full method, including attack restoration and the no-flinch branch.
    for (const owner of [pichu, new Projectile(pichu), new Projectile(pichu, true)]) {
        owner.APIInstance = { instance: {} };
        for (const amount of [1, 20, 999]) {
            Object.assign(bowser, {
                state: CState.IDLE, m_state: CState.IDLE, m_damage: 0,
                m_xKnockback: 0, m_yKnockback: 0, m_hitLag: 0,
                m_isMetal: false, m_sizeStatus: 0, m_paralysis: false,
                m_baseStats: { Stamina: 0 }, HasStance: false,
                m_attack: {}, m_hurtInterrupt: null, m_recoveryAmount: 0,
                m_matchResults: { DamageTaken: 0 }, m_lastHitID: 0,
                m_collision: { ground: true }, m_sprite: { stance: {} },
                m_eventManager: { dispatchEvent() {} }, APIInstance: { instance: {} },
                STAGEDATA: { GameRef: { LevelData: { specialModes: [] } }, GameEnded: false,
                    getPlayerByID: () => pichu, getQualitySettings: () => ({ hit_effects: false }) },
                validateHit: () => true, isGrabbedByFinalSmash: () => false,
                isInvincible: () => false, throbDamageCounter() {}, stackAttackID() {},
                dealDamage: n => { bowser.m_damage += n; },
                startActionShot: () => { throw new Error('Weak hit must not cause hitstun or paralysis'); },
                playGlobalSound() {}, resetKnockbackDecay() {},
                m_knockbackStackingTimer: { reset() {} },
                m_ricochetX: { finish() {} }, m_ricochetY: { finish() {} }
            });
            bowser.m_characterStats.CanReceiveDamage = true;
            bowser.m_characterStats.WindArmor = 0;
            const attack = { Owner: owner, PlayerID: owner.WasReversed ? 2 : -1,
                Frame: 'b', Damage: amount, Dizzy: 90, Stun: 90, Freeze: 90,
                Sleep: 90, Egg: true, Pitfall: 90, Paralysis: 90, Poison: 0,
                StaleMultiplier: 1, HasEffect: true, Power: 80, KBConstant: 100,
                BypassHeavyArmor: true, BypassSuperArmor: true, IsThrow: false,
                AttackID: -1, EffectID: null, EffectSound: null, exportAttackDamageData: () => ({}) };
            // Avoid unrelated player damage-credit bookkeeping for this reaction test.
            if (owner.WasReversed) bowser.m_attack.DisableLastHitUpdate = true;
            assert.equal(actualTakeDamage.call(bowser, attack), true);
            near(bowser.m_damage, amount * damageFactor);
            assert.equal(bowser.state, CState.IDLE);
            assert.equal(bowser.m_xKnockback, 0); assert.equal(bowser.m_yKnockback, 0);
            assert.equal(bowser.m_hitLag, 0);
            assert.equal(attack.HasEffect, true); assert.equal(attack.Power, 80);
            assert.equal(attack.KBConstant, 100); assert.equal(attack.Dizzy, 90);
        }
    }
});

test('Normal attack dizziness includes every normal family and excludes specials, items, throws and pummels', () => {
    const attacker = new Character(120, 64), victim = new Character(74, 30);
    const ratio = attacker.getStrengthGrabRatio(victim);
    const normalFrames = ['a', 'a_forward', 'a_forward_tilt', 'a_up_tilt', 'a_down',
        'a_forwardsmash', 'a_up', 'a_air', 'a_air_forward', 'a_air_backward',
        'a_air_up', 'a_air_down', 'crouch_attack', 'getup_attack', 'ledge_attack'];
    const hit = { Owner: attacker, Damage: 1, HasEffect: true, IsThrow: false };
    for (const Frame of normalFrames) assert.equal(victim.getStrengthDizzy({ ...hit, Frame }, attacker, ratio), 900);
    for (const Frame of ['b', 'b_up', 'b_down', 'b_forward_air', 'special', 'throw_forward', 'grab', 'item', null]) {
        assert.equal(victim.getStrengthDizzy({ ...hit, Frame }, attacker, ratio), 0);
    }
    const jab = { ...hit, Frame: 'a' };
    assert.equal(S.getDizzyDuration(2.499999), 0); assert.equal(S.getDizzyDuration(2.5), 900);
    assert.equal(victim.getStrengthDizzy(jab, attacker, 1), 0);
    assert.equal(victim.getStrengthDizzy({ ...jab, Damage: 0 }, attacker, ratio), 0);
    assert.equal(victim.getStrengthDizzy({ ...jab, HasEffect: false }, attacker, ratio), 0);
    assert.equal(victim.getStrengthDizzy({ ...jab, IsThrow: true }, attacker, ratio), 0);
    assert.equal(victim.getStrengthDizzy({ ...jab, Owner: new Projectile(attacker) }, attacker, ratio), 0);
    attacker.m_usingSpecialAttack = true;
    assert.equal(victim.getStrengthDizzy(jab, attacker, ratio), 0);
    attacker.m_usingSpecialAttack = false; attacker.state = CState.GRABBING;
    attacker.m_justPummeled = true; attacker.m_grabbed = [victim]; victim.state = CState.CAUGHT;
    assert.equal(victim.getStrengthDizzy(jab, attacker, ratio), 0);
});

test('Both native dizzy branches use the per-victim duration and honor status immunity', () => {
    const damage = method(characterSource, 'takeDamage').body;
    const branches = [...damage.matchAll(/if \([^\n]*strengthDizzy > 0[^\n]*/g)]
        .filter(m => !m[0].includes('wasDizzy) ||'));
    assert.equal(branches.length, 2);
    assert.equal((damage.match(/this.m_dizzyTimer = \(strengthDizzy/g) || []).length, 2);
    assert.ok(!damage.includes('attackObj.Dizzy ='));
    for (const branch of branches) {
        const opening = damage.indexOf('{', branch.index + branch[0].length);
        const apply = compileBody('strengthDizzy, attackObj, strengthMatchupArmored=false',
            'var wasDizzy:Boolean = false; var grabbedDuringFinalSmash:Boolean = false; var prevState:uint = 0; ' +
            branch[0] + '{' + bodyAt(damage, opening) + '}');
        const victim = new Character();
        Object.assign(victim, { m_damage: 10, m_facingForward: true, m_collision: { ground: true }, m_sprite: { stance: {} },
            m_stunCancelTimer: { reset() {} }, resetRotation() {}, killAllSpeeds() {} });
        const attack = { Dizzy: 0, Owner: new Character() };
        apply.call(victim, 90, attack);
        assert.equal(victim.state, CState.DIZZY); assert.equal(victim.m_dizzyTimer, 96);
        assert.equal(attack.Dizzy, 0);
        victim.state = CState.IDLE; victim.m_characterStats.StatusEffectImmunity = true;
        apply.call(victim, 90, attack); assert.equal(victim.state, CState.IDLE);
        victim.m_characterStats.StatusEffectImmunity = false;
        apply.call(victim, 90, attack, true); assert.equal(victim.state, CState.IDLE);
    }
});

test('Normal-projectile dizziness preserves launch provenance; specials and reflections cannot trigger it', () => {
    const attacker = new Character(120, 64), victim = new Character(74, 30);
    const ratio = attacker.getStrengthGrabRatio(victim);
    attacker.AttackStateData = { IsAttacking: true, IsThrow: false, Frame: 'a_air_forward' };
    const normal = new Projectile(attacker);
    normal.m_strengthNormalAttack = normal.isStrengthNormalAttackSource(attacker);
    assert.equal(normal.StrengthNormalAttack, true);
    attacker.AttackStateData.Frame = 'b';
    const special = new Projectile(attacker);
    special.m_strengthNormalAttack = special.isStrengthNormalAttackSource(attacker);
    assert.equal(special.StrengthNormalAttack, false);
    const attack = { Owner: normal, Frame: 'attack_idle', HasEffect: true, Damage: 1, IsThrow: false };
    assert.equal(victim.getStrengthDizzy(attack, attacker, ratio), 900);
    assert.equal(victim.getStrengthDizzy({ ...attack, Owner: special }, attacker, ratio), 0);
    const child = new Projectile(normal);
    child.m_strengthNormalAttack = child.isStrengthNormalAttackSource(normal);
    assert.equal(child.StrengthNormalAttack, true);
    normal.m_wasReversed = true;
    assert.equal(normal.StrengthNormalAttack, false);
    assert.equal(victim.getStrengthDizzy(attack, attacker, ratio), 0);
    assert.equal(child.isStrengthNormalAttackSource(normal), false);
    assert.equal(normal.isStrengthNormalAttackSource(null), false);
    attacker.AttackStateData.Frame = 'a'; attacker.AttackStateData.IsThrow = true;
    assert.equal(normal.isStrengthNormalAttackSource(attacker), false);
    attacker.AttackStateData.IsThrow = false; attacker.UsingFinalSmash = true;
    assert.equal(normal.isStrengthNormalAttackSource(attacker), false);
    assert.ok(projectileSource.includes('this.m_strengthNormalAttack = this.isStrengthNormalAttackSource(this.m_owner);'));
});

test('Stock DK cargo identification uses packaged statsName/linkage rather than the roster filename', () => {
    assert.equal(dkStats.statsName, 'donkeykong');
    assert.equal(dkStats.linkage_id, 'dkong');
    assert.equal(dkStats.weight1, 114); assert.equal(dkStats.height, 75);
    assert.ok(cargoCreateTimer.body.includes('this.m_characterStats.StatsName == "donkeykong"'));
    assert.ok(cargoCreateTimer.body.includes('this.m_characterStats.LinkageID == "dkong"'));
    assert.ok(!cargoCreateTimer.body.includes('this.m_characterStats.LinkageID == "donkeykong"'));
});

test('Strength dizziness clears launch and stays airborne until 900 unshortened grounded frames finish', () => {
    assert.equal(S.STRENGTH_DIZZY_FRAMES, 900);
    const victim = new Character();
    Object.assign(victim, {
        m_collision: { ground: false }, m_sprite: { stance: {} }, m_facingForward: true,
        m_stunCancelTimer: new context.FrameTimer(10),
        m_xSpeed: 4, m_ySpeed: -12, m_xKnockback: 30, m_yKnockback: -40,
        m_forcedCrash: true, m_forceTumbleFall: true,
        stopActionShot() { this.m_actionShot = this.m_paralysis = false; }, resetRotation() {},
        Struggle() { throw new Error('Mashing must not shorten strength dizziness'); },
        playFrame(frame) { this.frame = frame; }, currentFrameIs(frame) { return this.frame === frame; },
        initiateCrash() { throw new Error('Landing must not convert strength dizziness into a get-up'); }
    });
    victim.applyStrengthDizzy(900);
    assert.equal(victim.state, CState.DIZZY);
    for (const speed of ['m_xSpeed', 'm_ySpeed', 'm_xKnockback', 'm_yKnockback']) assert.equal(victim[speed], 0);
    assert.equal(victim.m_forcedCrash, false); assert.equal(victim.m_forceTumbleFall, false);
    for (let i = 0; i < 1000; i++) {
        victim.m_checkDizzy(); victim.checkFrameControl();
        assert.equal(victim.state, CState.DIZZY);
    }
    assert.equal(victim.m_strengthDizzyTimer, 900); assert.equal(victim.frame, 'falling');
    victim.m_collision.ground = true;
    victim.checkFrameControl();
    assert.equal(victim.state, CState.DIZZY); assert.equal(victim.frame, 'dizzy');
    for (let i = 0; i < 899; i++) { victim.m_checkDizzy(); victim.checkFrameControl(); }
    assert.equal(victim.state, CState.DIZZY); assert.equal(victim.m_strengthDizzyTimer, 1);
    victim.m_checkDizzy();
    assert.equal(victim.state, CState.IDLE); assert.equal(victim.m_strengthDizzyTimer, 0);
    assert.equal(victim.m_dizzyTimer, 0);
    victim.applyStrengthDizzy(900); victim.setState(CState.DEAD);
    assert.equal(victim.m_strengthDizzyTimer, 0);
    victim.setState(CState.CAUGHT); victim.applyStrengthDizzy(900);
    assert.equal(victim.state, CState.CAUGHT); assert.equal(victim.m_strengthDizzyTimer, 0);
    victim.setState(CState.IDLE); victim.m_characterStats.StatusEffectImmunity = true;
    victim.applyStrengthDizzy(900); assert.equal(victim.state, CState.IDLE);
});

test('Strength dizzy finalization runs after native launch, crash and knockback stacking in both hit branches', () => {
    const damage = method(characterSource, 'takeDamage').body;
    assert.equal((damage.match(/this.applyStrengthDizzy\(strengthDizzyBonus\);/g) || []).length, 2);
    for (const match of damage.matchAll(/this.applyStrengthDizzy\(strengthDizzyBonus\);/g)) {
        assert.match(damage.slice(match.index), /^this.applyStrengthDizzy\(strengthDizzyBonus\);\s*return \(true\);/);
    }
    const start = damage.indexOf('if (((strengthDizzyBonus > 0)');
    const end = damage.indexOf('applyKnockbackSpeed(tempVelocity, angle);', start);
    assert.ok(start > 0 && end > start);
    const suppress = compileBody('strengthDizzyBonus',
        'var strengthDizzy:int = 0; var strengthMatchupArmored:Boolean = false; ' +
        'var wasDizzy:Boolean = false; var tempVelocity:Number = 80; ' +
        damage.slice(start, end) + '\nreturn tempVelocity;');
    const victim = new Character(); victim.m_collision = { ground: true };
    assert.equal(suppress.call(victim, 900), 0); assert.equal(suppress.call(victim, 0), 80);
    // Native move/shield dizziness keeps its existing mash and airborne rules.
    Object.assign(victim, { state: CState.DIZZY, m_strengthDizzyTimer: 0, m_dizzyTimer: 90,
        m_dizzyShield: false, m_stunCancelTimer: new context.FrameTimer(10), Struggle: () => 12 });
    victim.m_checkDizzy(); assert.equal(victim.m_dizzyTimer, 77);
    victim.m_collision.ground = false; victim.m_checkDizzy();
    assert.equal(victim.state, CState.TUMBLE_FALL);
});

console.log(checks + ' strength regression checks passed. Animate/AIR build and gameplay testing still required.');
