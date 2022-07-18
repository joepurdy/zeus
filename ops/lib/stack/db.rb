module Stax
  class Db < Stack
    # no_commands do
    #   def cfer_parameters
    #     {
    #       vpc: stack(:vpc).stack_name
    #     }
    #   end
    # end

    # desc 'create', 'create stack'
    # def create
    #   ensure_stack :vpc   # make sure vpc stack is created first
    #   super               # create the stack
    # end
  end
end
