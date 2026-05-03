import random

_targets = []
_enabled = True


def register(op_path, par_name, low=None, high=None, every_n=1,
             discrete=False, choices=None):
    _targets.append({
        'op': op_path,
        'par': par_name,
        'low': low,
        'high': high,
        'every_n': every_n,
        'discrete': discrete,
        'choices': choices,
    })


def clear():
    _targets.clear()


def set_enabled(state):
    global _enabled
    _enabled = state


def update(cycle):
    if not _enabled:
        return
    for t in _targets:
        if cycle % t['every_n'] != 0:
            continue
        target_op = op(t['op'])
        if target_op is None:
            continue
        p = getattr(target_op.par, t['par'], None)
        if p is None:
            continue
        if t['choices'] is not None:
            p.val = random.choice(t['choices'])
        elif t['discrete']:
            p.val = random.randint(int(t['low']), int(t['high']))
        else:
            p.val = random.uniform(t['low'], t['high'])
