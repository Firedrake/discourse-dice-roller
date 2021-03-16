# Discourse Dice Roller

Adds a simple dice roller for play-by-post RPGs

## Usage

In a post, type `[roll 2d6]` - when the post is submitted, the plugin
will calculate the rolls. As standard, the post will become owned by
System to prevent further editing; functionality to reply with a new
post instead is under development.

Roll any reasonable number of dice of any size - `[roll 5d10]` `[roll
3d4]` `[roll d20]` all do what you'd expect.

Also `[roll d%]` and `[roll 4dF]` (a dF, used in FUDGE and FATE, has
the linear range -1..1).

Also add or subtract integers: `[roll 4d6+4]`, `[roll d10-1]`.

Also `[stress 4]`, `[stress 4+7]` – this is an Ars Magica stress die.
First parameter is the number of botch dice to be rolled in case of a
potential botch, second parameter is added to the total.

Also `[genesys X]`, for the _Genesys/Star Wars_ RPGs: X is a sequence
of letters and numbers, with optional spaces. Results are both listed
individually and summed.

- U - blUe, boost die
- U2 - 2 blue dice (etc.)
- G - Green, ability die
- Y - Yellow, proficiency die
- B - Black, setback die
- P - Purple, difficulty die
- R - Red, challenge die
- W - White, force die

Also `[totd X]`, for _Doctor Who: Time of the Daleks_. X is the
colours of dice (B black, G green, U blue, R red), with multipliers as
above: B4GU2 is four black, one green, two blue.

Also `[battle X]`, _Memoir '44_ battle dice. X is the number of dice
to roll.

More generally for dice pools: `[pool XdY]` (roll X dice each numbered
from 1 to Y, collate the results)

and for custom dice `[pool X;A,B,C]` (roll X dice each with custom
faces A, B, C, collate the results); if a face should occur more
often, duplicate it in the list.

## Installation

 * Add the plugin's repo url to your container's app.yml file

```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/Firedrake/discourse-dice-roller.git
```

 * Rebuild the container

```
cd /var/discourse
git pull
./launcher rebuild app
```

## Disclaimer

[dorthu](https://github.com/dorthu/discourse-dice-roller) wrote this
originally, though most of the actual core code has been replaced and
I've extended it quite a bit.

**THIS IS A WORK IN PROGRESS**

Some things are clearly not done:

 * A preview view to show that dice will be rolled
 * Reply with dice in a new post rather than editing the existing one
 * Admin-side configurations
