class MassEncryption::BatchEncryptionJob < MassEncryption::ApplicationJob
  def perform(batch, auto_enqueue_next: true)
      encrypt_batch = -> {
        if batch.present?
          batch.encrypt_now
          self.class.perform_later batch.next if auto_enqueue_next
        end
      }
    if defined?(ActsAsTenant)
      ActsAsTenant.without_tenant do
        encrypt_batch.call
      end
    else
      encrypt_batch.call
    end
  end

  ActiveSupport.run_load_hooks(:mass_encryption_batch_job, self)
end
