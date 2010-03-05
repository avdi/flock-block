require 'pathname'
require 'timeout'
module FlockBlock

  # A block-form helper for UNIX file locking.  Sugar for the File#flock
  # method.  Also adds timeouts.
  #
  # Supported
  #
  # NOTE: Raises Timeout::Error if unable to lock after waiting +seconds_to_wait+
  def flock(file_or_path, lock_type=:exclusive, seconds_to_wait=1)
    file = case file_or_path
           when String, Pathname then File.new(file_or_path.to_s)
           when File then file_or_path
           else raise ArgumentError, "file_or_path must be File or path to file"
           end
    lock_const = case lock_type
                 when :exclusive then File::LOCK_EX
                 when :shared    then File::LOCK_SH
                 when :nonblock  then File::LOCK_NB
                 else raise ArgumentError, "Unknown lock type #{lock_type}"
                 end

    Timeout.timeout(seconds_to_wait) do
      file.flock(lock_const)
    end
    yield
  ensure
    file.flock(File::LOCK_UN)
  end
end
