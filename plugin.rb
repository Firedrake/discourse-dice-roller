# name: dice_roller
# about: allows in-post dice rolling, for play-by-post RPGs
# version: 0
# authors: dorthu, Firedrake
# url: https://github.com/Firedrake/discourse-dice-roller

after_initialize do

    def roll_dice(type)
        num, size, delta = type.match(/([1-9]*)d([0-9]+)([-+][0-9]+)?/i).captures

        result = ''
        sum = 0

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

        if size=="F"
          delta=delta-2*num
          size="3"
        elsif size=="%"
          size="100"
        end

        (1..num).each do |n|
            roll = rand(1..size.to_i)
            result += "+ #{roll} "
            sum += roll
        end

        delta_str=delta.to_s
        if delta>-1
          delta_str="+" + delta_str
        end

        if num == 1
            "`d#{size}#{delta_str}:" + result[1..-1] + "`"
        elsif SiteSetting.dice_roller_sum_rolls
            "`#{num}d#{size}#{delta_str}:" + result[1..-1] + "= #{sum}`"
        else
            "`#{num}d#{size}#{delta_str}:" + result[1..-1] + "`"
        end
    end

    def inline_roll(post)
        post.raw.gsub!(/\[ ?roll *([1-9]*d[0-9]+([-+][0-9]+)?) *\]/i) { |c| roll_dice(c) }
        post.set_owner(User.find(-1), post.user)
    end

    def append_roll(post)
        puts '',"TODO - append rolled dice by the dice_roller_append_user"
    end

    on(:post_created) do |post, params|
        if SiteSetting.dice_roller_enabled and post.raw =~ /\[ ?roll *([1-9][0-9]*d[1-9][0-9]*([-+][1-9][0-9]+)?) *\]/i
            if SiteSetting.dice_roller_inline_rolls
                inline_roll(post)
            else
                append_roll(post)
            end
            post.save
        end
    end
end
