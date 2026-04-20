class AccountabilityRegenerateReportJob < ApplicationJob
  queue_as :default

  def perform(report_id)
    report = AccountabilityReport.find(report_id)
    
    AccountabilityReport.mark_as_in_progress(report_id)

    # report.update_status("Regenerating... (test hang)")
    # sleep 1.hours

    report.final_statistics(true)
    
  rescue => e
    # write a status that makes the UI stop polling + show error
    msg = "#{e.class}: #{e.message}".to_s[0, 300]
    report.update_status("ERROR: #{msg}")
    raise
  end
end