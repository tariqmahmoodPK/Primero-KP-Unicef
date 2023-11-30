# frozen_string_literal: true

# Model describing a referral of a record from one user to another.
class Referral < Transition
  after_create :send_referral_email

  def perform
    self.status = Transition::STATUS_INPROGRESS
    mark_service_referred(service_record)
    perform_system_referral unless remote
    record.last_updated_by = transitioned_by
    record.save! if record.has_changes_to_save?
  end

  def reject!(user, rejected_reason = nil)
    return unless in_progress?

    self.status = Transition::STATUS_REJECTED
    self.rejected_reason = rejected_reason
    self.responded_at = DateTime.now
    remove_assigned_user
    record.update_last_updated_by(user)
    record.save! && save!
  end

  def done!(user, rejection_note = nil)
    return unless accepted?

    self.status = Transition::STATUS_DONE
    current_service_record = service_record
    mark_service_implemented(current_service_record)
    mark_rejection(rejection_note, current_service_record)
    remove_assigned_user
    record.update_last_updated_by(user)
    record.save! && save!
  end

  def revoke!(user)
    self.status = Transition::STATUS_REVOKED
    remove_assigned_user
    record.update_last_updated_by(user)
    record.save! && save!
  end

  def accept!
    return unless in_progress?

    self.status = Transition::STATUS_ACCEPTED
    self.responded_at = DateTime.now
    save!
  end

  def process!(user, params)
    requested_status = params[:status]

    return if requested_status == status

    case requested_status
    when Transition::STATUS_REJECTED
      reject!(user, params[:rejected_reason])
    when Transition::STATUS_ACCEPTED
      accept!
    when Transition::STATUS_DONE
      done!(user, params[:rejection_note])
    end
  end

  def consent_given?
    case record.module_id
    when PrimeroModule::GBV
      record.consent_for_services
    when PrimeroModule::CP
      record.disclosure_other_orgs && record.consent_for_services
    else
      false
    end
  end

  def revoke_referral_email
    record = self
    reciever = User.find_by(user_name: record["transitioned_to"])

    CaseLifecycleEventsNotificationMailer.send_case_referred_revoked_notification(record, reciever).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: @record,
        cpo_user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  def accept_referral_email
    record = self
    reciever = User.find_by(user_name: record["transitioned_to"])

    CaseLifecycleEventsNotificationMailer.send_case_referred_accepted_notification(record, reciever).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: @record,
        cpo_user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  def reject_referral_email
    record = self
    reciever = User.find_by(user_name: record["transitioned_to"])

    CaseLifecycleEventsNotificationMailer.send_case_referred_rejected_notification(record, reciever).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: @record,
        cpo_user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  private

  def mark_rejection(rejection_note, service_object = nil)
    return unless rejection_note.present?

    self.rejection_note = rejection_note
    service_object['note_on_referral_from_provider'] = rejection_note if service_object.present?
  end

  def mark_service_referred(service_object)
    return if service_object.blank?

    service_object['service_status_referred'] = true
  end

  def mark_service_implemented(service_object)
    return unless service_object.present?

    if service_object['service_implemented_day_time'].blank?
      service_object['service_implemented_day_time'] = Time.zone.now.as_json
    end

    service_object['service_implemented'] = Serviceable::SERVICE_IMPLEMENTED
  end

  def service_record
    return if service_record_id.blank?

    record.services_section.find { |service| service['unique_id'] == service_record_id }
  end

  def perform_system_referral
    return if transitioned_to_user.nil?

    if record.assigned_user_names.present?
      record.assigned_user_names |= [transitioned_to]
    else
      record.assigned_user_names = [transitioned_to]
    end
  end

  def send_referral_email
    record = self
    reciever = User.find_by(user_name: record["transitioned_to"])

    CaseLifecycleEventsNotificationMailer.send_case_referred_to_user_notification(record, reciever).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: @record,
        cpo_user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

end
