class Download < ActiveRecord::Base

	hobo_model # Don't put anything above this

	# add in shared behaviour
	include ExtendedModelMixin

	fields do
		title       :string, :required
		description :text
		timestamps
	end

	belongs_to :uploader, :class_name => "User", :creator => true
	has_attached_file :attachment

	validates_attachment_presence :attachment
	
	# Check that a file is actually attached by looking for file name.
	#
	def clean_file_file_name (d)
		print d
		print "***"
		if ! d
			errors.add('file', 'need to attach a file')
		end
	end

	## Permissions:
	# - can be created by anyone who is a member of a country or an admin
	# - can be edited by the owner or an admin
	# This is because people can sign themselves up, and we want only "checked"
	# users to upload.
	def create_permitted?
		acting_user.signed_up? and (0 < acting_user.countries.length())
	end

	def update_permitted?
		acting_user.administrator? or owner_is? (acting_user)
	end

	def destroy_permitted?
		acting_user.administrator? or owner_is? (acting_user)
	end

	def view_permitted?(field)
		acting_user.signed_up? and (acting_user.administrator? or (0 < acting_user.countries.length()))
	end

end
