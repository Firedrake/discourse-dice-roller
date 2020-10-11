# coding: utf-8
# name: dice_roller
# about: allows in-post dice rolling, for play-by-post RPGs
# version: 0.0.1
# authors: dorthu, Firedrake
# url: https://github.com/Firedrake/discourse-dice-roller

after_initialize do

  def roll_dice(type)
    num, size, delta = type.match(/([0-9]*) *d *([0-9F%]+) *([-+] *[0-9]+)?/i).captures

    if num.nil? or num.empty?
      num = 1
    else
      num = num.to_i
    end

    if num > 256
      num = 256
    end

    low = 1
    high = 6
    if size=="F"
      low = -1
      high = 1
    elsif size=="%"
      high = 100
    elsif size =~ /^[0-9]+$/
      high = size.to_i
    end

    if delta.nil? or delta.empty?
      delta = 0
    else
      delta.gsub!(/ +/,'')
      delta = delta.to_i
    end

    delta_str=delta.to_s
    if delta>0
      delta_str="+" + delta_str
    elsif delta==0
      delta_str=""
    end

    result = Array.new
    sum = delta

    (1..num).each do |n|
      roll = rand(low..high)
      result.push(roll)
      sum += roll
    end

    if num == 1
      "`d#{size}#{delta_str}: #{sum}`"
    elsif SiteSetting.dice_roller_sum_rolls
      "`#{num}d#{size}#{delta_str}: #{result.join(' + ')} = #{sum}`"
    else
      "`#{num}d#{size}#{delta_str}:#{result.join(' + ')}`"
    end
  end

  def roll_stress(type)
    num, delta = type.match(/([0-9]+) *([-+] *[0-9]+)?/i).captures

    if num.nil? or num.empty?
      num = 1
    else
      num = num.to_i
    end

    if num > 256
      num = 256
    end

    if delta.nil? or delta.empty?
      delta = 0
    else
      delta.gsub!(/ +/,'')
      delta = delta.to_i
    end

    delta_str=delta.to_s
    if delta>0
      delta_str="+" + delta_str
    elsif delta==0
      delta_str=""
    end

    mul=1
    first=1
    done=0
    result = "stress #{num}#{delta_str}: "
    sum = delta

    while done==0 do
      roll = rand(1..10)
      if first == 1 and roll == 10
        botch=0
        if num > 0
          (1..num).each do
            sroll = rand(1..10)
            if sroll == 10
              botch += 1
            end
          end
        end
        if botch > 0
          result += "Botch: #{botch}/#{num}"
        else
          result += "0 (no botch), #{delta_str} = #{sum}"
        end
        done=1 
      elsif roll == 1
        mul *= 2
      else
        rm = roll * mul
        sum += rm
        result += "#{mul} × #{roll} = #{rm}, #{delta_str} = total #{sum}"
        done=1
      end
      first=0
    end

    "`" + result + "`"

  end

  def inline_roll(post)
    post.raw = "@#{post.user.username} asked for a die roll:\n" + post.raw
    post.raw.gsub!(/\[ *roll [^\]]*?\]/i) { |c| roll_dice(c) }
    post.raw.gsub!(/\[ *stress [^\]]*?\]/i) { |c| roll_stress(c) }
    post.set_owner(User.find(-1), post.user)
  end

  def append_roll(post)
    puts '',"TODO - append rolled dice by the dice_roller_append_user"
  end

  on(:post_created) do |post, params|
    if SiteSetting.dice_roller_enabled and (post.raw =~ /\[ *roll *([0-9]* *d *[F%1-9][0-9]* *([-+] *[1-9][0-9]*)?) *\]/i or post.raw =~ /\[ *stress *([0-9]+ *([-+] *[0-9]+)?) *\]/i)
      if SiteSetting.dice_roller_inline_rolls
        inline_roll(post)
      else
        append_roll(post)
      end
      post.save
    end
  end
end
