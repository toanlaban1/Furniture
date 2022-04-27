class OrdersController < ApplicationController
  protect_from_forgery with: :null_session
  
  before_action :set_order, only: [:show]
  def index
    user_id = params[:id] != nil ? params[:id] : nil
    status = params[:status] != nil ? params[:status] : nil 

    # render all orders
      all_order = Order.all
      all_order = all_order.where(status: status)
      render json: {
          code: 0,
          all_order: all_order,
          total: all_order.length
      }
  end

  def show
    render json: {
      order: @order,
      detail_information: @order.orders_products
    }, status: :ok
  end

  def update
    if params[:id] == nil
      render json: {
          code: 1,
          message: "Missing id of product"
      }
      return
    end
    order = Order.find_by(id: params[:id])
    if order.update(status: params[:status])
      render json: {
        code: 0,
        message: "Updated successfully!"
      }
    else
      render json: {
        code: 1,
        message: "Fail to update!"
      }
    end
  end

  def create
    
    new_order = Order.create(set_params.merge({user_id: params[:id]}))
    # array of id
    # quantity
    products = params[:products].map do |product|
                 Product.find_by(id: product)  
               end
    email = User.find_by(id: params[:id]).email 
    new_order.products << products
    
    # update quantity, size, color
    OrdersProduct.where(order_id: new_order.id).each_with_index.map do |product, index|
      product.update(quantity: params[:quantity][index])
      product.update(size: params[:size][index])
      product.update(color: params[:color][index])
    end
    
    render json: {
        code: 0,
        email: email,
        order: new_order,
        products: new_order.products,
        quantity: params[:quantity],
        size: params[:size],
        color: params[:color]
    }
  end

  private

  def set_params
    params.require(:order).permit(:status, :total_price, :description, :address)
  end

  def set_order 
    @order = Order.find_by(id: params[:id])
    if @order == nil
      render json: {
        code: 1,
        message: "Order does not exist"
      }
    end
  end
end