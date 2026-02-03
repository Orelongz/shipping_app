puts "Seeding development database..."

customer1 = Customer.find_or_create_by!(code: 'CUST001') do |c|
  c.name = 'Alpha Trading Co.'
  c.payment_terms_days = 15
end

customer2 = Customer.find_or_create_by!(code: 'CUST002') do |c|
  c.name = 'Beta Import Ltd.'
  c.payment_terms_days = 30
end

customer3 = Customer.find_or_create_by!(code: 'CUST003') do |c|
  c.name = 'Gamma Exports Inc.'
  c.payment_terms_days = 10
end

puts "Total number of customers: #{Customer.count}"

# Create bills of lading for customer1
# 1. Overdue 2 weeks ago
bill_of_lading_1 = BillOfLading.create(
  bl_number: 'BL_C1_OVERDUE_2W',
  customer_id: customer1.id,
  arrival_date: 2.weeks.ago,
  freetime: 5,
  number_of_20ft_containers: 2,
  number_of_40ft_containers: 1
)

# Create invoice for bill_of_lading_1 (overdue 2 weeks ago)
Invoice.find_or_create_by!(bl_number: bill_of_lading_1.bl_number, customer_id: customer1.id) do |inv|
  inv.amount = 5000.00
  inv.currency = 'USD'
  inv.due_date = 2.weeks.ago
  inv.status = 'draft'
end

# 2. Overdue yesterday
bill_of_lading_2 = BillOfLading.create(
  bl_number: 'BL_C1_OVERDUE_1D',
  customer_id: customer1.id,
  arrival_date: 1.day.ago,
  freetime: 0,
  number_of_20ft_containers: 1,
  number_of_40ft_containers: 2
)

# Create invoice for bill_of_lading_2 (overdue yesterday)
Invoice.find_or_create_by!(bl_number: bill_of_lading_2.bl_number, customer_id: customer1.id) do |inv|
  inv.amount = 3500.00
  inv.currency = 'USD'
  inv.due_date = 1.day.ago
  inv.status = 'paid'
end

# 3. Due in 2 weeks
bill_of_lading_3 = BillOfLading.create(
  bl_number: 'BL_C1_DUE_2W',
  customer_id: customer1.id,
  arrival_date: Date.current.to_datetime,
  freetime: 14,
  number_of_20ft_containers: 3,
  number_of_40ft_containers: 0
)

# Create invoice for bill_of_lading_3 (due in 2 weeks)
Invoice.find_or_create_by!(bl_number: bill_of_lading_3.bl_number, customer_id: customer1.id) do |inv|
  inv.amount = 2800.00
  inv.currency = 'USD'
  inv.due_date = 2.weeks.from_now
  inv.status = 'draft'
end

# Create bills of lading for customer2
# 1. Overdue 2 weeks ago
bill_of_lading_4 = BillOfLading.create(
  bl_number: 'BL_C2_OVERDUE_2W',
  customer_id: customer2.id,
  arrival_date: 2.weeks.ago,
  freetime: 3,
  number_of_20ft_containers: 4,
  number_of_40ft_containers: 2
)

# Create invoice for bill_of_lading_4 (overdue 2 weeks ago)
Invoice.find_or_create_by!(bl_number: bill_of_lading_4.bl_number, customer_id: customer2.id) do |inv|
  inv.amount = 7200.00
  inv.currency = 'USD'
  inv.due_date = 2.weeks.ago
  inv.status = 'draft'
end

# 2. Overdue yesterday
bill_of_lading_5 = BillOfLading.create(
  bl_number: 'BL_C2_OVERDUE_1D',
  customer_id: customer2.id,
  arrival_date: 1.day.ago,
  freetime: 0,
  number_of_20ft_containers: 2,
  number_of_40ft_containers: 3
)

# Create invoice for bill_of_lading_5 (overdue yesterday)
Invoice.find_or_create_by!(bl_number: bill_of_lading_5.bl_number, customer_id: customer2.id) do |inv|
  inv.amount = 6100.00
  inv.currency = 'USD'
  inv.due_date = 1.day.ago
  inv.status = 'draft'
end

# 3. Due in 2 weeks
bill_of_lading_6 = BillOfLading.create(
  bl_number: 'BL_C2_DUE_2W',
  customer_id: customer2.id,
  arrival_date: Date.current.to_datetime,
  freetime: 30,
  number_of_20ft_containers: 1,
  number_of_40ft_containers: 1
)
# Create invoice for bill_of_lading_6 (due in 2 weeks)
Invoice.find_or_create_by!(bl_number: bill_of_lading_6.bl_number, customer_id: customer2.id) do |inv|
  inv.amount = 4500.00
  inv.currency = 'USD'
  inv.due_date = 2.weeks.from_now
  inv.status = 'draft'
end

# 2. Overdue bill of lading for customer3
BillOfLading.create(
  bl_number: 'BL_C3_OVERDUE_1D',
  customer_id: customer3.id,
  arrival_date: 1.day.ago,
  freetime: 0,
  number_of_20ft_containers: 1,
  number_of_40ft_containers: 2
)

puts "Created #{BillOfLading.count} bills of lading"
puts "Created #{Invoice.count} invoices\n"

# Print API tokens
puts "=" * 50
puts "CUSTOMER API TOKENS"
puts "=" * 50
Customer.all.each do |customer|
  puts "#{customer.name} (#{customer.code}): #{customer.api_token}"
end

# Print admin token
puts "\n" + "=" * 50
puts "ADMIN TOKEN"
puts "=" * 50
admin_token = ENV['ADMIN_TOKEN'] || 'dev-secret-admin-key'
puts "ADMIN_TOKEN=#{admin_token}"

puts "\nDevelopment data seeded successfully!"
