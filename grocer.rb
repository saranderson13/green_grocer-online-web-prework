require 'pry'

def consolidate_cart(cart)
  consolidated = {}
  cart.each do |item|
    item.each do |item_name, attributes|
      if consolidated[item_name]
        consolidated[item_name][:count] += 1
      else
        consolidated[item_name] = attributes
        consolidated[item_name][:count] = 1
      end
    end
  end
  consolidated
end

def apply_coupons(cart, coupons)
  to_add = []
  cart.each { |item, attributes| coupons.each { |coupon| to_add << coupon if coupon[:item] == item } }

  to_add.each do |coupon_info|
    if cart[coupon_info[:item]][:count] >= coupon_info[:num]
      if cart["#{coupon_info[:item]} W/COUPON"]
        cart["#{coupon_info[:item]} W/COUPON"][:count] += 1
        cart[coupon_info[:item]][:count] -= coupon_info[:num]
      else
        cart["#{coupon_info[:item]} W/COUPON"] = {
          :price => coupon_info[:cost],
          :clearance => cart[coupon_info[:item]][:clearance],
          :count => 1
        }
        cart[coupon_info[:item]][:count] -= coupon_info[:num]
      end
    end
  end
  cart
end

def apply_clearance(cart)
  cart.each { |item, attributes| attributes[:price] = (attributes[:price] *= 0.8).round(2) if attributes[:clearance] }
end

def checkout(cart, coupons)
  cart = apply_clearance(apply_coupons(consolidate_cart(cart), coupons))
  total = 0

  cart.each { |item, attributes| total += (attributes[:price] * attributes[:count]) }

  total > 100 ? (total *= 0.9).round(2) : total
end
