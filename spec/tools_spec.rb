require File.dirname(__FILE__) + '/../lib/tools'

require 'tempfile'

include Devctm::Template::Tools

def in_a_temporary_directory(prefix = 'iatd')
  Tempfile.open(prefix) do |tf|
    dir = tf.path + '.dir'
    Dir.mkdir(dir, 0700)
    begin
      Dir.chdir(dir) { yield }
    ensure
      FileUtils.rm_r dir, :force => true, :secure => true
    end
  end
end

def in_a_temporary_directory_with_skel(verb)
  in_a_temporary_directory do
    FileUtils.mkdir_p "skel/#{verb}"
    yield
  end
end

# Ick.  This is the core of the run method from Rails::TemplateRunner
# for Rails 2.3.3.  This should be sufficient to verify that the find
# command that we're running is doing what we want for Rails 2.3.3,
# but if Rails changes how run works, this could give us misleading
# results.

def run(command)
  `#{command}`
end

def file(path, contents = '')
  File.open(path, 'w') { |f| f.write contents }
end

describe Devctm::Template::Tools do
  describe 'app_name' do

    before(:each) do
      should_receive(:root).and_return('.')
    end

    it 'returns the last component of root' do
      app_name.should == 'devctm_template'
    end

    it 'returns a frozen object' do
      app_name.should be_frozen
    end
  end

  describe 'tell_git_about_empty_directories' do

    # Combine the test for an empty directories with tests for
    # directories with files because we know that the work is being
    # done by a semi-complex find command and mixing different types
    # of directories may find problems that might not be found if all
    # directories were either empty or non-empty.

    it 'places a .gitignore in empty directories and only empty directories' do
      in_a_temporary_directory do
        FileUtils.mkdir_p('a_sub/empty')

        FileUtils.mkdir_p('a_sub/not_empty')
        FileUtils.touch('a_sub/not_empty/a_file')

        FileUtils.mkdir_p('empty')

        FileUtils.mkdir_p('not_empty')
        FileUtils.touch('not_empty/a_file')

        tell_git_about_empty_directories

        File.exists?('a_sub/empty/.gitignore').should be_true
        File.exists?('a_sub/not_empty/.gitignore').should_not be_true
        File.exists?('empty/.gitignore').should be_true
        File.exists?('not_empty/.gitignore').should_not be_true
      end
    end
  end

  describe 'fix_skel_migrations' do

    before(:each) do
      def setup
        in_a_temporary_directory_with_skel('expect/db/migrate') do
          yield
        end
      end
    end

    it 'raises FileNotFound with no match' do
      setup do
        file 'skel/expect/db/migrate/20090820170233_create_users.rb'
        lambda { fix_skel_migrations('skel') }.should raise_error(FileNotFound)
      end
    end

    it 'raises AmbiguousMigration with multiple matches' do
      setup do
        file 'skel/expect/db/migrate/20090820170233_create_users.rb'
        FileUtils.mkdir_p('db/migrate')
        file 'db/migrate/20090820170233_create_users.rb'
        file 'db/migrate/20090820170234_create_users.rb'
        lambda { fix_skel_migrations('skel') }.should raise_error(AmbiguousMigration)
      end
    end

    it "renames the source file when there's just one match" do
      setup do
        lambda { fix_skel_migrations('skel') }.should_not raise_error
      end
    end
  end

  describe 'update_app_from_skel' do
    describe 'skel/expect' do

      before(:each) do
        def setup
          in_a_temporary_directory_with_skel('expect') { yield }
        end
      end

      describe 'raises an error when' do
        it "the target file isn't there" do
          setup do
            file 'skel/expect/not_there'
            lambda { update_app_from_skel('skel') }.should raise_error(FileNotFound)
          end
        end

        it "the target contents don't match" do
          setup do
            file 'skel/expect/there', 'this is a test'
            file 'there', 'this was a test'
            lambda { update_app_from_skel('skel') }.should raise_error(ContentsDiffer)
          end
        end
      end

      describe 'succeeds if' do
        it "the expected file is zero-length and the target is there" do
          setup do
            file 'skel/expect/there'
            file 'there', 'this was a test'
            lambda { update_app_from_skel('skel') }.should_not raise_error
            File.exist?('there').should be_true
          end
        end

        it "the expected file is non-zero length and the contents match" do
          setup do
            file 'skel/expect/there', '  foo'
            file 'there', 'foo'
            lambda { update_app_from_skel('skel') }.should_not raise_error
            File.exist?('there').should be_true
          end
        end
      end
    end

    describe 'skel/remove' do

      before(:each) do
        def setup
          in_a_temporary_directory_with_skel('remove') { yield }
        end
      end

      describe 'raises an error when' do
        it 'the target file is not there' do
          setup do
            file 'skel/remove/not_there'
            lambda { update_app_from_skel('skel') }.should raise_error(FileNotFound)
          end
        end

        it 'the target contents differ from the remove file' do
          setup do
            file 'skel/remove/there', 'this is a test'
            file 'there', 'this was a test'
            lambda { update_app_from_skel('skel') }.should raise_error(ContentsDiffer)
          end
        end
      end

      describe 'succeeds if' do
        it "the expected file is zero-length and the target is there" do
          setup do
            file 'skel/remove/there'
            file 'there', 'this was a test'
            lambda { update_app_from_skel('skel') }.should_not raise_error
            File.exist?('there').should be_false
          end
        end

        it "the expected file is non-zero length and the contents match" do
          setup do
            file 'skel/remove/there', '  foo'
            file 'there', 'foo'
            lambda { update_app_from_skel('skel') }.should_not raise_error
            File.exist?('there').should be_false
          end
        end
      end
    end

    describe 'skel/modify' do

      before(:each) do
        def setup
          in_a_temporary_directory_with_skel('modify') { yield }
        end
      end

      it 'raises an error if the target file is not there' do
        setup do
          file 'skel/modify/not_there'
          lambda { update_app_from_skel('skel') }.should raise_error(FileNotFound)
        end
      end

      it 'updates the target file if the target file is already there' do
        setup do
          file 'skel/modify/there', 'Now is the time...'
          file 'there', 'When?'
          lambda { update_app_from_skel('skel') }.should_not raise_error
          IO.read('there').should == 'Now is the time...'
        end
      end
    end

    describe 'skel/add' do

      before(:each) do
        def setup
          in_a_temporary_directory_with_skel('add') { yield }
        end
      end

      it 'raises an error if the target file is already there' do
        setup do
          file 'skel/add/there'
          file 'there'
          lambda { update_app_from_skel('skel') }.should raise_error(FileExists)
        end
      end

      it 'creates the target file if the target file is not already there' do
        setup do
          file 'skel/add/not_yet_there', 'success'
          lambda { update_app_from_skel('skel') }.should_not raise_error
          IO.read('not_yet_there').should == 'success'
        end
      end
    end
  end

  describe 'ask_for_password' do
    before(:each) do
      @identifier = 'admin'
    end

    it "prompts w/o default if there isn't one" do
      should_receive(:`).and_return('')
      should_receive(:ask).with('Password for admin?').and_return('')
      ask_for_password(@identifier)
    end

    it 'prompts with a default if one is available' do
      should_receive(:`).and_return('xyzzy')
      should_receive(:ask).with('Password for admin (default is "xyzzy")?').and_return('')
      ask_for_password(@identifier)
    end

    it "returns the value of ask (if non-zero length or no default)" do
      should_receive(:`).and_return('')
      should_receive(:ask).with('Password for admin?').and_return('test pw')
      ask_for_password(@identifier).should == 'test pw'
    end

    it "returns the default if ask returns a zero-length string" do
      should_receive(:`).and_return('xyzzy')
      should_receive(:ask).with('Password for admin (default is "xyzzy")?').and_return('')
      ask_for_password(@identifier).should == 'xyzzy'
    end
  end

end
