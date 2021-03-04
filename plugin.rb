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

  def roll_genesys(type)
    dice=Hash.new
    dn={ 'U' => 'boost', 'G' => 'ability', 'Y' => 'proficiency',
         'B' => 'setback', 'P' => 'difficulty', 'R' => 'challenge',
         'W' => 'force'}
    rs=['success','failure','advantage','threat','triumph','threat']
    dn.keys.each do |i|
      dice[i]=0
    end
    dtype=''
    type.split(/([A-Z]|[0-9]+)/i).each do |i|
      if i != ''
        if i.to_i > 0
          if dice.has_key?(dtype)
            dice[dtype] += i.to_i-1
          end
        else
          j=i
          j.capitalize
          if dice.has_key?(j)
            dtype=j
            dice[dtype] += 1
          end
        end
      end
    end
    reslist=Array.new
    restext=Array.new
    dice.keys.each do |i|
      if dice[i]>0
        1.upto(dice[i]).each do
          r=Hash.new
          if i == 'U'
            roll=rand(1..6)
            if roll==3
              r={'success' => 1}
            elsif roll==4
              r={'success' => 1, 'advantage' => 1}
            elsif roll==5
              r={'advantage' => 2}
            elsif roll==6
              r={'advantage' => 1}
            end
          elsif i == 'G'
            roll=rand(1..8)
            if roll==2 or roll==3
              r={'success' => 1}
            elsif roll==4
              r={'success' => 2}
            elsif roll==5 or roll==6
              r={'advantage' => 1}
            elsif roll==7
              r={'success' => 1, 'advantage' => 1}
            elsif roll==8
              r={'advantage' => 2}
            end
          elsif i == 'Y'
            roll=rand(1..12)
            if roll==2 or roll==3
              r={'success' => 1}
            elsif roll==4 or roll==5
              r={'success' => 2}
            elsif roll==6
              r={'advantage' => 1}
            elsif roll==7 or roll==8 or roll==9
              r={'success' => 1, 'advantage' => 1}
            elsif roll==10 or roll==11
              r={'advantage' => 2}
            elsif roll==12
              r={'triumph' => 1}
            end
          elsif i == 'B'
            roll=rand(1..6)
            if roll==3 or roll==4
              r={'failure' => 1}
            elsif roll==5 or roll==6
              r={'threat' => 1}
            end
          elsif i == 'P'
            roll=rand(1..8)
            if roll==2
              r={'failure' => 1}
            elsif roll==3
              r={'failure' => 2}
            elsif roll==4 or roll==5 or roll==6
              r={'threat' => 1}
            elsif roll==7
              r={'threat' => 2}
            elsif roll==8
              r={'failure' => 1,'threat' => 1}
            end
          elsif i == 'R'
            roll=rand(1..12)
            if roll==2 or roll==3
              r={'failure' => 1}
            elsif roll==4 or roll==5
              r={'failure' => 2}
            elsif roll==6 or roll==7
              r={'threat' => 1}
            elsif roll==8 or roll==9
              r={'failure' => 1, 'threat' => 1}
            elsif roll==10 or roll==11
              r={'threat' => 2}
            elsif roll==12
              r={'despair' => 1}
            end
          elsif i == 'W'
            roll=rand(1..12)
            if roll<7
              r={'darkside' => 1}
            elsif roll==7
              r={'darkside' => 2}
            elsif roll<10
              r={'lightside' => 1}
            else
              r={'lightside' => 2}
            end
          end
          reslist.push(r)
          restext.push("#{i} #{dn[i]}: " + stringify_hash(r))
        end
      end
    end
    total=Hash.new
    total.default=(0)
    reslist.each do |r|
      total.merge!(r) {|k,o,n| o+n}
    end
    if total.has_key?('triumph')
      total['success'] += total['triumph']
    end
    if total.has_key?('despair')
      total['failure'] += total['despair']
    end
    if total.has_key?('success') and total.has_key?('failure')
      a=total['success']-total['failure']
      if a>0
        total.delete('failure')
        total['success']=a
      elsif a<0
        total.delete('success')
        total['failure']=-a
      else
        total.delete('success')
        total.delete('failure')
      end
    end
    if total.has_key?('advantage') and total.has_key?('threat')
      a=total['advantage']-total['threat']
      if a>0
        total.delete('threat')
        total['advantage']=a
      elsif a<0
        total.delete('advantage')
        total['threat']=-a
      else
        total.delete('advantage')
        total.delete('threat')
      end
    end
    restext.push("total: " + stringify_hash(total))
    return "`" + restext.join("`\n`") + "`"
  end

  def roll_battle(count)
    num=1
    if count != "" then
      m = count.match(/([0-9]+)/)
      if !m.nil? then
        num=m[1]
      end
    end
    
    if num.nil? then
      num = 1
    else
      num = num.to_i
    end
    if num<1 then
      num = 1
    end
    results=mkpool(num,["Infantry","Infantry","Armor","Grenade","Star","Flag"])
    return "`battle #{num}: " + stringify_hash(results) + "`"
  end

  def roll_pool(type)
    sa=Array.new
    m=type.match(/([1-9][0-9]*) *; *(.+)/i)
    if m.nil? then
      m=type.match(/([0-9]*) *d *([0-9]+)/i);
      if m.nil? then
        return "invalid pool #{type}"
      else
        num, sides = m.captures
        if num.nil? then
          num = 1
        else
          num = num.to_i
        end
        if num<1 then
          num = 1
        end
        sides=sides.to_i
        sa=1.upto(sides).map{|i| i.to_s}
      end
    else
      num, sides = m.captures
      num = num.to_i
      sa=sides.split(/ *, */)
    end
    results=mkpool(num,sa)
    return "`pool #{num}: " + stringify_hash(results) + "`"
  end

  def roll_pool(type)
    sa=Array.new
    m=type.match(/([0-9]*) *d *([0-9]+)/i);
    if m.nil? then
      m=type.match(/([1-9][0-9]*) *; *(.+)/i)
      if m.nil? then
        return "invalid pool #{type}"
      else
        num, sides = m.captures
        num = num.to_i
        sa=sides.split(/ *, */)
      end
    else
      num, sides = m.captures
      if num.nil? then
        num = 1
      else
        num = num.to_i
      end
      if num<1 then
        num = 1
      end
      sides=sides.to_i
      sa=1.upto(sides).map{|i| i.to_s}
    end
    results=mkpool(num,sa)
    return "`pool #{num}: " + stringify_hash(results) + "`"
  end

  def mkpool(count,keys)
    results=Hash.new
    keys.each do |k|
      results[k]=0
    end
    kl=keys.length
    1.upto(count) do
      results[keys[rand(kl)-1]]+=1
    end
    results.keys.map {|k| results[k]==0?results.delete(k):''}
    return results
  end

  def stringify_hash(r)
    t='blank'
    unless r.empty?()
      t=r.keys.map {|k| r[k]==1?k:"#{r[k]} × #{k}"}.join(', ')
    end
    return t
  end

  def inline_roll(post)
    post.raw = "@#{post.user.username} asked for a die roll:\n" + post.raw
    post.raw.gsub!(/\[ *roll [^\]]*?\]/i) { |c| roll_dice(c) }
    post.raw.gsub!(/\[ *stress [^\]]*?\]/i) { |c| roll_stress(c) }
    post.raw.gsub!(/\[ *genesys [^\]]*?\]/i) { |c| roll_genesys(c) }
    post.raw.gsub!(/\[ *pool [^\]]*?\]/i) { |c| roll_pool(c) }
    post.raw.gsub!(/\[ *battle [^\]]*?\]/i) { |c| roll_battle(c) }
    post.set_owner(User.find(-1), post.user)
  end

  def append_roll(post)
    puts '',"TODO - append rolled dice by the dice_roller_append_user"
  end

  on(:post_created) do |post, params|
    if SiteSetting.dice_roller_enabled and (post.raw =~ /\[ *roll *([0-9]* *d *[F%1-9][0-9]* *([-+] *[1-9][0-9]*)?) *\]/i or post.raw =~ /\[ *stress *([0-9]+ *([-+] *[0-9]+)?) *\]/i or post.raw =~ /\[ *genesys [A-Z0-9]+ *\]/i or post.raw =~ /\[ *(pool|battle)/i)
      if SiteSetting.dice_roller_inline_rolls
        inline_roll(post)
      else
        append_roll(post)
      end
      post.save
    end
  end
end
