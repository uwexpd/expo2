# Helper method to get the best available email body content
# Returns a hash with :html and :text keys (values may be nil if not present)
# lib/email_body_extractor.rb
module EmailBodyExtractor
    def self.extract(email)
       
        return nil unless email.is_a?(Mail::Message)

        # Initialize result hash
        body_content = { html: nil, text: nil }

        if email.multipart?
        # Extract HTML part if available
        if email.html_part
            body_content[:html] = email.html_part.body.decoded
        else
            # Sometimes html_part might be nil; try to find in parts
            html_part = email.parts.find { |p| p.content_type =~ /text\/html/ }
            body_content[:html] = html_part.body.decoded if html_part
        end

        # Extract plain text part if available
        if email.text_part
            body_content[:text] = email.text_part.body.decoded
        else
            # Sometimes text_part might be nil; try to find in parts
            text_part = email.parts.find { |p| p.content_type =~ /text\/plain/ }
            body_content[:text] = text_part.body.decoded if text_part
        end
        else
        # Not multipart: treat entire body as text (or html if content_type says so)
        content_type = email.content_type || ''
        if content_type =~ /text\/html/
            body_content[:html] = email.body.decoded
        else
            body_content[:text] = email.body.decoded
        end
        end

        body_content         
    end
  end