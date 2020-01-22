desc "Deactivated when auto remove date less than today "
    task :deactivate_opportunties => :environment do
    	opportunties = ResearchOpportunity.expired
    	puts "total of expired opportunties is #{opportunties.size}"
    	opportunties.each do |oppt|
    		oppt.active = 0    		
    		if oppt.save!(:validate => false)
    			puts "opportunty #{oppt.id} is deactived"
    		end
    	end
    end
