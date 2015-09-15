require File.expand_path('../../test_helper', __FILE__)
require_relative '../../app/jobs/synchronize_human_tasks_job'
class SynchronizeHumanTasksJobTest < ActiveJob::TestCase

  test 'initial' do
    puts 'TESTANDO'
    expected = 'teste'
    result = SynchronizeHumanTasksJob.perform_now(1)
    assert_equal(result.login,expected)
  end

end
