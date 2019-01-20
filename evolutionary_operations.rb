class Evolutionary_Operations
  @@index_value = 0

  def initialise(population_size,individual_length,random_list,random_value)
    bits = ""
    population = Array.new()
    for i in 0..population_size-1
      for j in 0..individual_length-1
        @@random_list_elements,@@index_value = index_control(random_list,@@index_value)
        if @@random_list_elements < random_value
          bits << "0"
        else
          bits << "1"
        end
      end
      population.insert(i,bits)
      bits = ""
    end
    return population
  end

  def index_control(random_list,random_index)
    if random_index/(random_list.size-1) == 1 && random_index % (random_list.size-1) == 0
      return random_list[random_index],random_index = 0
    end
    return random_list[random_index].to_f, random_index+=1
  end

  def evaluate(population,population_size,individual_length,population_members_value,population_members_weight,knapsack_weight)
    fitness = 0
    total_weight = 0
    weight_index = 0
    value_index = 0
    individual_length = population_members_weight.size
    population_fitness = Array.new()

    for i in 0..population_size-1 #populasyondaki her kişi için fitness hesaplamayı sağlar.
      (population[i].to_s.chars).each do|bit|#populasyondaki her bireyin bit dizilimine ulaşmayı sağlar.
        total_weight += (bit.to_i)*(population_members_weight[weight_index].to_i) #her bit weight değeri ile çarpılır.
        weight_index += 1
      end
      if total_weight <= knapsack_weight
        (population[i].to_s.chars).each do|bit|#populasyondaki her bireyin bit dizilimine ulaşmayı sağlar.
          fitness += (bit.to_i)*(population_members_value[value_index].to_i)
          value_index += 1
        end
        population_fitness.insert(i,fitness.to_s)
      else
        population_fitness.insert(i,"0")
      end
      fitness = 0
      total_weight = 0
      weight_index = 0
      value_index = 0
    end
    return population_fitness
  end

  def parent_select(population,tournament_size,population_size,random_list,population_fitness)
    lambda = population_size-1
    n = population_size
    parent_pool_bits = [lambda]# bit dizilimini tutacak.
    parent_pool_fitness = [lambda]# fitness dizilimini tutacak.
    tournament_value = tournament_size # her bir turnuvanın kaç kişilik olacağı
    bits_of_the_selected_parent = [tournament_size-1] #turnuvada seçilen parentların bitleri
    fitness_of_the_selected_parent = [tournament_size-1] #turnuvada seçilen parentların fitnessları

    for number_of_tournaments in 0..lambda #tüm popülasyona turnuva uygulayacak.
      for t_value in 0..tournament_value-1
        @@random_list_elements,@@index_value = index_control(random_list,@@index_value)
        i = ((@@random_list_elements * n) - 1).ceil #yukarı yuvarlama işlemi
        bits_of_the_selected_parent[t_value] = population[i]
        fitness_of_the_selected_parent[t_value] = population_fitness[i]
      end
      # parentlardan fitnessı en iyi olan  seçilir.
      tournament_value = tournament_size
      optimum_fitness = 0
      for t_value in 0..tournament_value-1
        if fitness_of_the_selected_parent[t_value].to_i > optimum_fitness
          optimum_fitness = fitness_of_the_selected_parent[t_value].to_i
          optimum_parent = bits_of_the_selected_parent[t_value]
        end
      end
      parent_pool_bits[number_of_tournaments] = optimum_parent
      parent_pool_fitness[number_of_tournaments] = optimum_fitness.to_s
    end

    #  print parent_pool_bits
    #  puts "---"
    # print parent_pool_fitness

    return  parent_pool_bits,parent_pool_fitness
  end

  def recombine(parent_pool_bits,random_list)
    number_of_parent_to_match = (parent_pool_bits.length - (parent_pool_bits.length % 2)).to_i #ikili parent kalmayınca eşleşme olamaz.

    @@first_parents = Array.new()
    @@second_parents = Array.new()

    count = 0
    while count <= number_of_parent_to_match-1 #çift sayılı indislerde 1.parentlar bulunur.
      @@first_parents.push(parent_pool_bits[count].to_s)
      count += 2
    end


    count = 1
    while count <= number_of_parent_to_match-1 #tek sayılı indislerde 2.parentlar bulunur.
      @@second_parents.push(parent_pool_bits[count].to_s)
      count += 2
    end

    @@random_list_elements,@@index_value = index_control(random_list,@@index_value)

    @@crossover_point = @@random_list_elements.to_s

    point = @@crossover_point.split('.')
    point.each do |p|
      if p != "0"
        @@crossover_point = (p.to_i)-1
      end
    end

    child1 = Array.new()
    child2 = Array.new()

    for i in 0..(number_of_parent_to_match/2)-1
      first_child_bits = ""
      second_child_bits = ""

      for j in 0..@@crossover_point
        first_child_bits << @@first_parents[i][j].to_s
      end

      for k in 0..@@crossover_point
        second_child_bits << @@second_parents[i][k].to_s
      end

      for z in @@crossover_point+1..parent_pool_bits.length-1
        second_child_bits << @@first_parents[i][z].to_s
      end

      for m in @@crossover_point+1..parent_pool_bits.length-1
        first_child_bits << @@second_parents[i][m].to_s
      end

      child1.insert(i,first_child_bits)
      child2.insert(i,second_child_bits)
    end
    return child1,child2, number_of_parent_to_match
  end

  def mutation(random_list,mutation_value,lambda,child1,child2,population_members_value,population_members_weight,knapsack_weight,parent_pool_bits,number_of_parent_to_match)

    child = Array.new()
    @@child_fitness = Array.new() # tüm çocukların fitness değerini tutar
    individual_lenght = population_members_value.size #popülasyondaki bireylerin bit uzunluğunu tutar

    for j in 0..child1.length-1
      child.push(child1[j].to_s)
    end

    for j in 0..child2.length-1
      child.push(child2[j].to_s)
    end
    child_bits = ""
    for i in 0..lambda-1  #lambda çocuk sayısını tutmalı.
      (child[i].to_s.chars.to_a).each do |c_bit|
        @@random_list_elements,@@index_value = index_control(random_list,@@index_value)
        if @@random_list_elements < mutation_value
          c_bit == "1" ? c_bit = "0" : c_bit = "1"
          child_bits << c_bit
        else
          child_bits << c_bit
        end
      end
      child[i] = child_bits
      child_bits = ""
    end

    @@child_fitness = evaluate(child,number_of_parent_to_match,individual_lenght,population_members_value,population_members_weight,knapsack_weight)
    return child, @@child_fitness
  end

  def survival_select(population,child,population_size,population_fitness,child_fitness,iteration_value)

    p = Array.new()

    for j in 0..population.length-1
      p.push(population[j].to_s)
    end

    for j in 0..child.length-1
      p.push(child[j].to_s)
    end
    p_fitness = Array.new()

    for j in 0..population_fitness.length-1
      p_fitness.push(population_fitness[j].to_s)
    end

    for j in 0..child_fitness.length-1
      p_fitness.push(child_fitness[j].to_s)
    end

    new_population = Array.new()
    new_population_fitness = Array.new()
    pop_swap = 0
    fitness_swap = 0

    # fitness sıralamasıyla populasyon sıralamasının aynı olmasını sağlar.
    for i in 0..p_fitness.length-1
      for j in 1..p_fitness.length-1
        if p_fitness[i].to_i > p_fitness[j].to_i
          fitness_swap = p_fitness[j]
          p_fitness[j] = p_fitness[i]
          p_fitness[i]= fitness_swap
          pop_swap = p[j]
          p[j] = p[i]
          p[i] = pop_swap
        end
      end
    end

    @@iteration_sum = 0
    # pop_size kadar new_pop oluştur.
    for i in 0..population_size-1
      new_population.insert(i,p[i])
      new_population_fitness.insert(i,p_fitness[i])
      @@iteration_sum += p_fitness[i].to_i
    end

    # iteration_max
    @@iteration_max = new_population_fitness[1].to_i
    puts @@iteration_max
    # puts "-"
    # iteratinon_min
    @@iteration_min = new_population_fitness[22].to_i
    # puts new_population_fitness.last
    # puts""
    # print new_population_fitness[1]
    # puts "--"
    # iteration_avg
    @@iteration_avg = (@@iteration_sum / new_population_fitness.length)
    # puts @@iteration_avg

    return @@iteration_max,@@iteration_min,@@iteration_avg,new_population,new_population_fitness

  end
end

