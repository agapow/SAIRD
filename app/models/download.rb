class Download < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title       :string
    description :text
    timestamps
  end

	belongs_to :uploader, :class_name => "User", :creator => true
	has_attached_file :file

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
