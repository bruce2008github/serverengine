#
# ServerEngine
#
# Copyright (C) 2012-2013 Sadayuki Furuhashi
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module ServerEngine

  class Worker
    def initialize(server, worker_id)
      @server = server
      @config = server.config
      @logger = @server.logger
      @worker_id = worker_id
    end

    attr_reader :server, :worker_id
    attr_accessor :config, :logger

    def before_fork
    end

    def run
      raise NoMethodError, "Worker#run method is not implemented"
    end

    def stop
    end

    def reload
    end

    def after_start
    end

    def install_signal_handlers
      w = self
      SignalThread.new do |st|
        st.trap(Daemon::Signals::GRACEFUL_STOP) { w.stop }
        st.trap(Daemon::Signals::IMMEDIATE_STOP, 'SIG_DFL')

        st.trap(Daemon::Signals::GRACEFUL_RESTART) { w.stop }
        st.trap(Daemon::Signals::IMMEDIATE_RESTART, 'SIG_DFL')

        st.trap(Daemon::Signals::RELOAD) {
          w.logger.reopen!
          w.reload
        }
        st.trap(Daemon::Signals::DETACH) { w.stop }

        st.trap(Daemon::Signals::DUMP) { Sigdump.dump }
      end
    end

    def main
      run
    end
  end

end
