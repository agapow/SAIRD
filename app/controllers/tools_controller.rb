

class ToolsController < ApplicationController
	
	def index
	end
	
	def upload_susceptibilities
		session[:results] = process_form(ToolForms::UploadSusceptibilitiesForm, request)
	end
	
	def upload_thresholds
		session[:results] = process_form(ToolForms::UploadThresholdsForm, request)
	end
	
	def extended_query
		session[:results] = process_form(ToolForms::ExtendedQueryForm, request)
	end
	
	def graph_resistance
		session[:results] = process_form(ToolForms::GraphResistanceForm, request)
	end

end


def process_form(tf, req)
	# XXX: this is not great and puts far to much work in the controller
	# TODO: refactor or more to a more logical place
	
	# The torturous logic of this method:
	# - we are handed a toolform & request ...
	# - only process form if there has been a submission, otherwise results are nil
	results = nil
	errors = []
	pp "FLASh LOOKS LIKE THIS"
	pp flash
	pp flash[:error]
	if ! req.parameters['_submit'].nil?
		# check for errors in parameters and clean them up
		conv_params, errors = tf.is_valid?(req.parameters)
		pp req.parameters
		# if we get parameters back, it's okay, process it
		if errors.size() == 0
			results, errors = tf.process(conv_params)
		end
		# if there are any errors (from validation or processing), show them
		if 0 < errors.size()
			flash[:error] = "Please fix the following errors: <ul>%s</ul>" %
				errors.collect { |e| "<li>#{e}</li>" }.join("\n")
			results = nil
		end
	end

	# return results, whch should be nil if no action (error or no process),
	# an empty array if processing suceeded but there's no results, and a
	# non-empty result if there are results.
	return results
end
