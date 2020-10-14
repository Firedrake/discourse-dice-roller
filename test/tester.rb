#! /usr/bin/ruby
# coding: utf-8

def after_initialize
  yield
end

$onblock=Proc.new { }

def on(post,&block)
  $onblock=block
end

class Ss
  def dice_roller_enabled
    return true
  end
  def dice_roller_sum_rolls
    return true
  end
  def dice_roller_inline_rolls
    return true
  end
end

SiteSetting=Ss.new

class User
  def self.find(dummy)
    return "USERNAME"
  end
  def username
    return "USERNAME"
  end
end

class Post
  attr_reader :raw, :user
  def initialize(content)
    @raw=content
    @user=User.new
  end
  def raw=(newcontent)
    @raw=newcontent
  end
  def set_owner(dummyA,dummyB)
  end
  def save
  end
end

require_relative "../plugin"
require "test/unit"

class TestDice < Test::Unit::TestCase
  
  def test_d
    srand(1602262750)
    assert_match(/^`d100: 76`$/,roll_dice("d100"))
  end

  def test_1d
    srand(1602262750)
    assert_match(/^`d100: 76`$/,roll_dice("1d100"))
  end

  def test_percent
    srand(1602262750)
    assert_match(/^`d%: 76`$/,roll_dice("d%"))
  end

  def test_3d
    srand(1602262750)
    assert_match(/^`3d6: 4 \+ 2 \+ 3 = 9`$/,roll_dice("3d6"))
  end

  def test_3d_post
    post=Post.new('[roll 3d6]')
    srand(1602262750)
    $onblock.call(post)
    assert_match(/USERNAME asked for a die roll:.*`3d6: 4 \+ 2 \+ 3 = 9`/m,post.raw)
  end

  def test_fudge
    srand(1602262750)
    assert_match(/^`4dF: 0 \+ 1 \+ -1 \+ 1 = 1`$/,roll_dice("4dF"))
  end

  def test_delta
    srand(1602262750)
    assert_match(/^`d2\+10: 12`$/,roll_dice("d2+10"))
  end

  def test_stress_base
    srand(160226275)
    assert_match(/^`stress 10\+10: 1 × 6 = 6, \+10 = total 16`$/,roll_stress("10+10"))
  end

  def test_stress_crit
    srand(160226293)
    assert_match(/^`stress 10\+10: 4 × 7 = 28, \+10 = total 38`$/,roll_stress("10+10"))
  end

  def test_stress_botch
    srand(1602262751)
    assert_match(/^`stress 10\+10: Botch: 1\/10`$/,roll_stress("10+10"))
  end

  def test_gen1
    srand(1602262751)
    assert_match(/total: advantage, failure, lightside`$/,roll_genesys('UGYBPRW'))
  end

  def test_gen1_post
    post=Post.new('[genesys UGYBPRW]')
    srand(1602262751)
    $onblock.call(post)
    assert_match(/USERNAME asked for a die roll:.*total: advantage, failure, lightside`$/m,post.raw)
  end

  def test_gen2
    srand(1602262751)
    assert_match(/total: success, 3 × advantage`$/,roll_genesys('GGYX'))
  end

  def test_gen2_multiplier
    srand(1602262751)
    assert_match(/total: success, 3 × advantage`$/,roll_genesys('G2YX'))
  end

  def test_gen2_spaces
    srand(1602262751)
    assert_match(/total: success, 3 × advantage`$/,roll_genesys('G2 Y'))
  end

  def test_gen3
    srand(1602262755)
    assert_match(/total: triumph, 4 × advantage, 3 × failure, despair`$/,roll_genesys('Y6R6'))
  end

end
