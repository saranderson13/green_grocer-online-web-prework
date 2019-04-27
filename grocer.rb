require 'pry'

def consolidate_cart(cart)
  # Add a "count" key to indicate the quantity of each item.
  # If there are multiple of any item, keep only one entry for it.
  

  consolidated = {}
  check_count = []
  
  cart.each do |item_with_information|
    item_with_information.each do |item_name, item_information|
      consolidated[item_name] = item_information
      if consolidated[item_name][:count] == nil
        consolidated[item_name][:count] = 1
      else 
        check_count << item_name 
        check_count.each { |item_to_check| consolidated[item_name][:count] += 1 if item_to_check == item_name }
      end
    end
  end
  consolidated
end

def apply_coupons(cart, coupons)
  # Apply quantity dependent coupons.
  # If there is a coupon for an item, check the quantity for that item
  # Create a combined "w/ coupon" item with the adjusted price and quantity.
  # If there is a remainder that the coupon can't be applied to,
  # adjust the original entry to reflect the remaining quantity.


  # EXTRACT INFORMATION FROM COUPONS AND CART:
  # NAMES OF ITEMS THAT HAVE COUPONS, CLEARANCE STATUS, AND COUPON COUNT.
  carryover_info = {}
  cart.each do |item, item_info|
    coupons.each do |coupon_hash|
      # binding.pry
      if item == coupon_hash[:item]
        if carryover_info[item] == nil
          carryover_info[item] = {} 
          carryover_info[item][:clearance] = item_info[:clearance]
          carryover_info[item][:coupon_num_items] = coupon_hash[:num]
          carryover_info[item][:coupon_price] = coupon_hash[:cost]
        end
        carryover_info[item][:coupon_count] == nil ? carryover_info[item][:coupon_count] = 1 : carryover_info[item][:coupon_count] += 1
      end
    end
  end

  carryover_info.each do |item, info|
    
    # ADD ITEM WITH COUPON
    cart["#{item} W/COUPON"] = {
      price: carryover_info[item][:coupon_price],
      clearance: carryover_info[item][:clearance],
      count: carryover_info[item][:coupon_count]
    }
    
    # binding.pry
    # ADJUST QUANTITY OF ORIGINAL ITEM
    # item:count = remainder of items that were not included in a coupon
    cart[item][:count] = cart[item][:count] % carryover_info[item][:coupon_num_items]
    
    binding.pry
  end
  
  # binding.pry
  cart
end








def apply_clearance(cart)
  # DISCOUNT THE PRICE OF EVERY ITEM MARKED CLEARANCE BY 20%
  
  cart.each { |item, info| info[:price] = (info[:price] * 0.8).round(2) if info[:clearance] == true }
end

def checkout(cart, coupons)
  # Consolidate cart.
  # Apply coupon discounts. 
  # Apply clearance discounts. 
  # If total > $100, apply additional 10% discount.
  
  consolidated = consolidate_cart(cart)
  total = 0
  
  consolidated = apply_coupons(consolidated, coupons)
  consolidated = apply_clearance(consolidated)
  
  consolidated.each { |item, info| total += info[:price] }
  
  total = (total * 0.9).round(2) if total > 100
  total
end








