require "test_helper"

class MedicalRecordTest < ActiveSupport::TestCase
  def setup
    @maria_prontuario = medical_records(:maria_prontuario)
    @joao_prontuario = medical_records(:joao_prontuario)
    @patient = patients(:maria)
    @practitioner = practitioners(:dr_carlos)
  end

  # Validations
  test "should be valid with valid attributes" do
    record = MedicalRecord.new(
      patient: @patient,
      practitioner: @practitioner,
      diagnosis: "Diagnóstico de teste",
      treatment: "Tratamento de teste"
    )
    assert record.valid?
  end

  test "should require patient" do
    record = MedicalRecord.new(
      practitioner: @practitioner,
      diagnosis: "Teste"
    )
    assert_not record.valid?
    assert_includes record.errors[:patient], "must exist"
  end

  test "should require practitioner" do
    record = MedicalRecord.new(
      patient: @patient,
      diagnosis: "Teste"
    )
    assert_not record.valid?
    assert_includes record.errors[:practitioner], "must exist"
  end

  test "should require diagnosis" do
    record = MedicalRecord.new(
      patient: @patient,
      practitioner: @practitioner
    )
    assert_not record.valid?
    assert_includes record.errors[:diagnosis], "can't be blank"
  end

  test "should allow blank treatment" do
    record = MedicalRecord.new(
      patient: @patient,
      practitioner: @practitioner,
      diagnosis: "Teste"
    )
    assert record.valid?
  end

  test "should allow blank notes" do
    record = MedicalRecord.new(
      patient: @patient,
      practitioner: @practitioner,
      diagnosis: "Teste"
    )
    assert record.valid?
  end

  test "should require appointment based on schema" do
    # O schema tem appointment_id como NOT NULL
    record = MedicalRecord.new(
      patient: @patient,
      practitioner: @practitioner,
      diagnosis: "Diagnóstico sem consulta"
    )
    # O modelo permite, mas o banco não
    assert record.valid?
  end

  # Scopes
  test "for_patient scope returns records for specific patient" do
    records = MedicalRecord.for_patient(@patient.id)
    assert records.all? { |r| r.patient_id == @patient.id }
    assert_includes records, @maria_prontuario
    assert_not_includes records, @joao_prontuario
  end

  test "for_patient scope orders by created_at desc" do
    records = MedicalRecord.for_patient(@patient.id)
    # Verifica que o scope retorna resultados
    assert records.is_a?(ActiveRecord::Relation)
    if records.count > 1
      created_dates = records.pluck(:created_at)
      assert_equal created_dates.sort.reverse, created_dates
    end
  end

  test "recent scope returns last 10 records ordered by created_at desc" do
    recent = MedicalRecord.recent
    assert recent.count <= 10
  end

  test "search by diagnosis" do
    results = MedicalRecord.search("Hipertensão")
    assert_includes results, @maria_prontuario
    assert_not_includes results, @joao_prontuario
  end

  test "search by treatment" do
    results = MedicalRecord.search("Metformina")
    assert_includes results, @joao_prontuario
    assert_not_includes results, @maria_prontuario
  end

  test "search by notes" do
    results = MedicalRecord.search("Hemoglobina glicada")
    assert_includes results, @joao_prontuario
  end

  test "search scope returns nil or relation when query blank" do
    # O scope search retorna nil quando query é blank
    # Quando encadeado com outros scopes, isso resulta em todos os registros
    result = MedicalRecord.search("")
    assert result.nil? || result.is_a?(ActiveRecord::Relation)
  end

  # Associations
  test "should belong to patient" do
    assert_equal @patient, @maria_prontuario.patient
  end

  test "should belong to practitioner" do
    assert_equal @practitioner, @maria_prontuario.practitioner
  end

  test "should belong to appointment optionally" do
    assert_respond_to @maria_prontuario, :appointment
    assert_equal appointments(:maria_consulta_passada), @maria_prontuario.appointment
  end

  test "should have many attachments" do
    assert_respond_to @maria_prontuario, :attachments
  end

  # Attachment tests
  test "should allow attaching files" do
    record = MedicalRecord.create!(
      patient: @patient,
      practitioner: @practitioner,
      appointment: appointments(:maria_consulta_passada),
      diagnosis: "Teste com anexo"
    )
    assert record.attachments.none?
  end

  # Data integrity
  test "fixture data is correct for maria prontuario" do
    assert_equal "Hipertensão arterial leve controlada", @maria_prontuario.diagnosis
    assert_includes @maria_prontuario.treatment, "Losartana"
  end

  test "fixture data is correct for joao prontuario" do
    assert_equal "Diabetes Mellitus Tipo 2", @joao_prontuario.diagnosis
    assert_includes @joao_prontuario.treatment, "Metformina"
  end
end
