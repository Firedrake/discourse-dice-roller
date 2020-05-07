# name: dice_roller
# about: allows in-post dice rolling, for play-by-post RPGs
# version: 0.0.1
# authors: dorthu, Firedrake
# url: https://github.com/Firedrake/discourse-dice-roller

after_initialize do

  def roll_dice(type)
    num, size, delta = type.match(/([1-9]*)d([0-9F%]+)([-+][0-9]+)?/i).captures

    if num.nil? or num.empty?
      num = 1
    else
      num = num.to_i
    end

    if delta.nil? or delta.empty?
      delta = 0
    else
      delta = delta.to_i
    end

    delta_str=delta.to_s
    if delta>0
      delta_str="+" + delta_str
    elsif delta==0
      delta_str=""
    end

    low = 1
    high = 6
    if size=="F"
      low = -1
      high = 1
    elsif size=="%"
      high = 100
    else
      high = size.to_i
    end

    result = ''
    sum = delta

    (1..num).each do |n|
      roll = rand(low..high)
      result += "+ #{roll} "
      sum += roll
    end

    if num == 1
      "`d#{size}#{delta_str}:" + sum + "`"
    elsif SiteSetting.dice_roller_sum_rolls
      "`#{num}d#{size}#{delta_str}:" + result[1..-1] + "= #{sum}`"
    else
      "`#{num}d#{size}#{delta_str}:" + result[1..-1] + "`"
    end
  end

  def inline_roll(post)
    post.raw.gsub!(/\[ ?roll *([1-9]*d[F%0-9]+([-+][0-9]+)?) *\]/i) { |c| roll_dice(c) }
    post.raw.gsub!(/^/,"@#{post.user.username} asked for a die roll:\n")
    post.set_owner(User.find(-1), post.user)
  end

  def append_roll(post)
    puts '',"TODO - append rolled dice by the dice_roller_append_user"
  end

  on(:post_created) do |post, params|
    if SiteSetting.dice_roller_enabled and post.raw =~ /\[ ?roll *([0-9]*d[F%1-9][0-9]*([-+][1-9][0-9]*)?) *\]/i
      if SiteSetting.dice_roller_inline_rolls
        inline_roll(post)
      else
        append_roll(post)
      end
      post.save
    end
  end
end
