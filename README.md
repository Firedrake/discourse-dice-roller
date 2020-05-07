# Discourse Dice Roller

Adds a simple dice roller for play-by-post RPGs

## Usage

In a post, type `[roll 2d6]` - when the post it submitted, it will calculate
the rolls.

Roll any number of dice of any size - `[roll 5d10]` `[roll 3d4]` `[roll d20]`
all do what you'd expect.

Also `[roll 4d6+4]`, `[roll d10-1[`, `[roll d%]` and `[roll 4dF]` (a
dF has the range -1..1).

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

Modified from Dorthu's code. I don't know Ruby.

**THIS IS A WORK IN PROGRESS**

Some things are clearly not done:

 * A preview view to show that dice will be rolled
 * Reply with dice in a new post rather than editing the existing one
 * When editing the existing post, indicate the original poster somehow
 * Admin-side configurations
