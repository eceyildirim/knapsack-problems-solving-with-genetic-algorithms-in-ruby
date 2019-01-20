require_relative 'evolutionary_operations'
class Evolutionary_Computing
  random_list = []
  random_list = [0.06,0.32,0.87,0.02,0.15,0.47,0.36,0.53,0.32,0.39,0.39,0.26,0.27,0.21,0.73,0.42,0.69,0.32,0.3]

  # random_list
  # print "Rastgele Liste Giriniz:"
  # random_list = gets.chomp.to_i

  # population size
  # print "Popülasyon Boyutunu Girin:"
  size = 30
  @@population_size = size.to_i

  # tournament size
  # print "Turnuva Boyutunu Girin(k):"
  k = 5
  @@tournament_size = k.to_i

  # # mutation
  # print "Mutasyon Olasılığını Girin:"
  m = 0.07
  @@mutation_value = m.to_f

  # iteration
  # print "İterasyon Sayısını Girin:"
  @@generation = 82

  # knapsack size
  # print "Çanta Boyutunu Girin(W):"
  w_max = 47
  @@knapsack_weight = w_max.to_i

  # element w
  # print "Elemanların Ağırlıklarını Virgülle Ayırarak Girin:"
  w = "14,13,11,13,10,11,13,14,11,13,15,11,11,11,5,15,15,6,12,12,7,8,6"
  @@population_members_weight = w.split(',')

  # element v
  # print "Elemanların Değerlerini Virgülle Ayırarak Girin:"
  v = "18,22,21,23,18,22,19,22,25,17,23,21,11,13,20,11,13,14,15,17,25,14,17"
  @@population_members_value = v.split(',')



  @@methods = Evolutionary_Operations.new
  @@index_value = 0

  @@random_value = 0.5

  @@population = @@methods.initialise(@@population_size,@@population_members_value.length,random_list,@@random_value)


  while @@generation > 0
    @@population_fitness = @@methods.evaluate(@@population,@@population_size,@@population_members_value.length,@@population_members_value,@@population_members_weight,@@knapsack_weight)
    #
    @@parent_pool_bits,@@parent_pool_fitness = @@methods.parent_select(@@population,@@tournament_size,@@population_size,random_list,@@population_fitness)
    #
    @@child1,@@child2,@@number_of_parent_to_match= @@methods.recombine(@@parent_pool_bits,random_list)
    #  #
    @@child, @@child_fitness = @@methods.mutation(random_list,@@mutation_value,@@population_size,@@child1,@@child2,@@population_members_value,@@population_members_weight,@@knapsack_weight,@@parent_pool_bits,@@number_of_parent_to_match)
    #  #
    @@i_max,@@i_min,@@i_avg,@@new_population,@@new_population_fitness  = @@methods.survival_select(@@population,@@child,@@population_size,@@population_fitness,@@child_fitness,@@generation)

    @@population = @@new_population

    @@population_fitness = @@new_population_fitness

    @@generation -= 1
  end

  # print "#{@@i_max} iterasyonların maxları \n"
  # print "#{@@i_min} iterasyonların minleri \n"
  # print "#{@@i_avg} iterasyonların avgleri \n"

end

