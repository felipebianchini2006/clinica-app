# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# === USERS ===
puts "Creating users..."

admin = User.find_or_create_by!(email: "admin@clinica.com") do |u|
  u.name = "Administrador"
  u.password = "password123"
  u.role = :admin
end
puts "  ✓ Admin: admin@clinica.com / password123"

# === PRACTITIONERS (com seus users) ===
puts "Creating practitioners..."

dr_carlos_user = User.find_or_create_by!(email: "carlos@clinica.com") do |u|
  u.name = "Dr. Carlos Eduardo Mendes"
  u.password = "password123"
  u.role = :practitioner
end

dr_carlos = Practitioner.find_or_create_by!(crm: "CRM-SP 123456") do |p|
  p.name = "Dr. Carlos Eduardo Mendes"
  p.specialty = "Clínica Geral"
  p.phone = "(11) 3456-7890"
  p.user = dr_carlos_user
end
puts "  ✓ Dr. Carlos: carlos@clinica.com / password123"

dra_patricia_user = User.find_or_create_by!(email: "patricia@clinica.com") do |u|
  u.name = "Dra. Patrícia Lima"
  u.password = "password123"
  u.role = :practitioner
end

dra_patricia = Practitioner.find_or_create_by!(crm: "CRM-SP 654321") do |p|
  p.name = "Dra. Patrícia Lima"
  p.specialty = "Pediatria"
  p.phone = "(11) 3456-7891"
  p.user = dra_patricia_user
end
puts "  ✓ Dra. Patrícia: patricia@clinica.com / password123"

# Receptionist
receptionist = User.find_or_create_by!(email: "recepcao@clinica.com") do |u|
  u.name = "Maria Santos"
  u.password = "password123"
  u.role = :receptionist
end
puts "  ✓ Recepcionista: recepcao@clinica.com / password123"

# === PATIENTS ===
puts "Creating patients..."

maria = Patient.find_or_create_by!(cpf: "123.456.789-01") do |p|
  p.name = "Maria Silva Santos"
  p.birth_date = Date.new(1985, 3, 15)
  p.phone = "(11) 98765-4321"
  p.email = "maria.silva@email.com"
  p.address = "Rua das Flores, 123 - São Paulo/SP"
  p.notes = "Alergia a dipirona. Hipertensão controlada."
end

joao = Patient.find_or_create_by!(cpf: "987.654.321-00") do |p|
  p.name = "João Carlos Oliveira"
  p.birth_date = Date.new(1970, 8, 22)
  p.phone = "(11) 91234-5678"
  p.email = "joao.oliveira@email.com"
  p.address = "Av. Brasil, 456 - São Paulo/SP"
  p.notes = "Diabético tipo 2. Uso contínuo de Metformina."
end

ana = Patient.find_or_create_by!(cpf: "456.789.123-00") do |p|
  p.name = "Ana Paula Costa"
  p.birth_date = Date.new(1992, 11, 30)
  p.phone = "(11) 99876-5432"
  p.email = "ana.costa@email.com"
  p.address = "Rua Augusta, 789 - São Paulo/SP"
  p.notes = "Gestante - acompanhamento pré-natal."
end

pedro = Patient.find_or_create_by!(cpf: "321.654.987-00") do |p|
  p.name = "Pedro Henrique Souza"
  p.birth_date = Date.new(2015, 5, 10)
  p.phone = "(11) 94567-8901"
  p.email = "mae.pedro@email.com"
  p.address = "Rua Consolação, 321 - São Paulo/SP"
  p.notes = "Paciente pediátrico. Mãe: Fernanda Souza."
end

lucia = Patient.find_or_create_by!(cpf: "654.321.987-00") do |p|
  p.name = "Lúcia Fernanda Almeida"
  p.birth_date = Date.new(1955, 12, 3)
  p.phone = "(11) 93456-7890"
  p.email = "lucia.almeida@email.com"
  p.address = "Rua Paulista, 1000 - São Paulo/SP"
  p.notes = "Idosa. Acompanhamento geriátrico."
end

puts "  ✓ #{Patient.count} patients created"

# === APPOINTMENTS ===
puts "Creating appointments..."

# Consultas passadas (completed) - skip validation for past dates
past_appt_1 = Appointment.find_or_initialize_by(
  patient: maria,
  practitioner: dr_carlos,
  scheduled_at: 7.days.ago.change(hour: 9, min: 0)
)
unless past_appt_1.persisted?
  past_appt_1.assign_attributes(
    duration_minutes: 30,
    status: :completed,
    notes: "Consulta de rotina realizada. Pressão arterial controlada."
  )
  past_appt_1.save!(validate: false)
end

past_appt_2 = Appointment.find_or_initialize_by(
  patient: joao,
  practitioner: dr_carlos,
  scheduled_at: 5.days.ago.change(hour: 10, min: 30)
)
unless past_appt_2.persisted?
  past_appt_2.assign_attributes(
    duration_minutes: 45,
    status: :completed,
    notes: "Acompanhamento diabetes. Solicitado novos exames."
  )
  past_appt_2.save!(validate: false)
end

# Consultas de hoje/amanhã (usando horários que garantem estar no futuro)
today_appt_1 = Appointment.find_or_create_by!(
  patient: lucia,
  practitioner: dr_carlos,
  scheduled_at: 1.day.from_now.change(hour: 14, min: 0)
) do |a|
  a.duration_minutes = 30
  a.status = :confirmed
  a.notes = "Check-up geral"
end

today_appt_2 = Appointment.find_or_create_by!(
  patient: pedro,
  practitioner: dra_patricia,
  scheduled_at: 1.day.from_now.change(hour: 15, min: 0)
) do |a|
  a.duration_minutes = 30
  a.status = :scheduled
  a.notes = "Consulta pediátrica de rotina"
end

# Consultas futuras
future_appt_1 = Appointment.find_or_create_by!(
  patient: maria,
  practitioner: dr_carlos,
  scheduled_at: 3.days.from_now.change(hour: 9, min: 0)
) do |a|
  a.duration_minutes = 30
  a.status = :scheduled
  a.notes = "Retorno - verificar exames"
end

future_appt_2 = Appointment.find_or_create_by!(
  patient: ana,
  practitioner: dra_patricia,
  scheduled_at: 2.days.from_now.change(hour: 10, min: 0)
) do |a|
  a.duration_minutes = 45
  a.status = :confirmed
  a.notes = "Pré-natal - 7º mês"
end

future_appt_3 = Appointment.find_or_create_by!(
  patient: joao,
  practitioner: dr_carlos,
  scheduled_at: 5.days.from_now.change(hour: 11, min: 0)
) do |a|
  a.duration_minutes = 30
  a.status = :scheduled
  a.notes = "Retorno com resultados de exames"
end

puts "  ✓ #{Appointment.count} appointments created"

# === MEDICAL RECORDS ===
puts "Creating medical records..."

MedicalRecord.find_or_create_by!(
  patient: maria,
  practitioner: dr_carlos,
  appointment: past_appt_1
) do |m|
  m.diagnosis = "Hipertensão arterial leve controlada"
  m.treatment = "Manter uso de Losartana 50mg 1x/dia. Dieta hipossódica. Atividade física regular."
  m.notes = "Paciente apresenta boa adesão ao tratamento. PA 130x80mmHg. Peso estável."
end

MedicalRecord.find_or_create_by!(
  patient: joao,
  practitioner: dr_carlos,
  appointment: past_appt_2
) do |m|
  m.diagnosis = "Diabetes Mellitus Tipo 2 - Controlado"
  m.treatment = "Metformina 850mg 2x/dia. Dieta com restrição de carboidratos simples. Caminhada 30min/dia."
  m.notes = "Glicemia de jejum 110mg/dL. Hemoglobina glicada 6.8%. Solicitar exames de controle em 3 meses."
end

puts "  ✓ #{MedicalRecord.count} medical records created"

# === INVOICES ===
puts "Creating invoices..."

Invoice.find_or_create_by!(
  patient: maria,
  appointment: past_appt_1
) do |i|
  i.amount = 250.00
  i.status = :paid
  i.due_date = 5.days.ago.to_date
  i.paid_at = 5.days.ago
  i.description = "Consulta clínica geral"
end

Invoice.find_or_create_by!(
  patient: joao,
  appointment: past_appt_2
) do |i|
  i.amount = 300.00
  i.status = :paid
  i.due_date = 3.days.ago.to_date
  i.paid_at = 2.days.ago
  i.description = "Consulta + solicitação de exames"
end

Invoice.find_or_create_by!(
  patient: lucia,
  appointment: today_appt_1
) do |i|
  i.amount = 280.00
  i.status = :pending
  i.due_date = 7.days.from_now.to_date
  i.description = "Check-up geral"
end

Invoice.find_or_create_by!(
  patient: ana,
  appointment: future_appt_2
) do |i|
  i.amount = 350.00
  i.status = :pending
  i.due_date = 10.days.from_now.to_date
  i.description = "Consulta pré-natal"
end

# Uma fatura atrasada para testes
Invoice.find_or_create_by!(
  patient: pedro,
  appointment: today_appt_2
) do |i|
  i.amount = 200.00
  i.status = :pending
  i.due_date = 2.days.ago.to_date
  i.description = "Consulta pediátrica (ATRASADA para teste)"
end

puts "  ✓ #{Invoice.count} invoices created"

puts ""
puts "=" * 50
puts "🎉 Seed completed successfully!"
puts "=" * 50
puts ""
puts "📋 Summary:"
puts "   Users: #{User.count}"
puts "   Practitioners: #{Practitioner.count}"
puts "   Patients: #{Patient.count}"
puts "   Appointments: #{Appointment.count}"
puts "   Medical Records: #{MedicalRecord.count}"
puts "   Invoices: #{Invoice.count}"
puts ""
puts "🔐 Login credentials:"
puts "   Admin:         admin@clinica.com / password123"
puts "   Dr. Carlos:    carlos@clinica.com / password123"
puts "   Dra. Patrícia: patricia@clinica.com / password123"
puts "   Recepção:      recepcao@clinica.com / password123"
puts ""
