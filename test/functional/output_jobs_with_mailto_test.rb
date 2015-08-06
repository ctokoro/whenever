require 'test_helper'

class ExtendedString < String
  def without_empty_lines
    @without_empty_lines ||= self.lines.map{|line| line.chomp }.reject{|line| line.empty? }
  end
end

class OutputJobsWithMailtoTest < Whenever::TestCase
  test "defined job with a mailto argument" do
    output = ExtendedString.new Whenever.cron \
    <<-file
      every 2.hours do
        command "blahblah", mailto: 'someone@example.com'
      end
    file

    assert_equal 'MAILTO=someone@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output.without_empty_lines.shift
  end

  test "defined job with every method's block and a mailto argument" do
    output = ExtendedString.new Whenever.cron \
    <<-file
      every 2.hours, mailto: 'someone@example.com' do
        command "blahblah"
      end
    file

    assert_equal 'MAILTO=someone@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output.without_empty_lines.shift
  end

  test "defined job which overrided mailto argument in the block" do
    output = ExtendedString.new Whenever.cron \
    <<-file
      every 2.hours, mailto: 'of_the_block@example.com' do
        command "blahblah", mailto: 'overrided_in_the_block@example.com'
      end
    file

    assert_equal 'MAILTO=overrided_in_the_block@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output.without_empty_lines.shift
  end

  test "defined some jobs with various mailto argument" do
    output = ExtendedString.new Whenever.cron \
    <<-file
      every 2.hours do
        command "blahblah"
      end

      every 2.hours, mailto: 'john@example.com' do
        command "blahblah_of_john"
        command "blahblah2_of_john"
      end

      every 2.hours, mailto: 'sarah@example.com' do
        command "blahblah_of_sarah"
      end

      every 2.hours do
        command "blahblah_of_martin", mailto: 'martin@example.com'
        command "blahblah2_of_sarah", mailto: 'sarah@example.com'
      end

      every 2.hours do
        command "blahblah2"
      end
    file

    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2'", output.without_empty_lines.shift

    assert_equal 'MAILTO=john@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_john'", output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2_of_john'", output.without_empty_lines.shift

    assert_equal 'MAILTO=sarah@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_sarah'", output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2_of_sarah'", output.without_empty_lines.shift

    assert_equal 'MAILTO=martin@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_martin'", output.without_empty_lines.shift
  end

  test "defined some jobs with environment mailto define and various mailto argument" do
    output = ExtendedString.new Whenever.cron \
    <<-file
      mailto 'default@example.com'

      every 2.hours do
        command "blahblah"
      end

      every 2.hours, mailto: 'sarah@example.com' do
        command "blahblah_by_sarah"
      end

      every 2.hours do
        command "blahblah_by_john", mailto: 'john@example.com'
      end

      every 2.hours do
        command "blahblah2"
      end
    file

    assert_equal 'MAILTO=default@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2'", output.without_empty_lines.shift

    assert_equal 'MAILTO=sarah@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_by_sarah'", output.without_empty_lines.shift

    assert_equal 'MAILTO=john@example.com', output.without_empty_lines.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_by_john'", output.without_empty_lines.shift
  end
end
