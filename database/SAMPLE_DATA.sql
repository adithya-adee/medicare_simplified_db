-- Insert sample doctors
INSERT INTO doctor_consultation (doctor_name, doctor_address, doctor_phone_no, doctor_qualification, doctor_specialization)
VALUES 
('Dr. Sarah Johnson', '123 Medical Lane, Mumbai', '+91-9876543210', 'MD, MBBS', 'Cardiology'),
('Dr. Rajesh Patel', '456 Health Avenue, Delhi', '+91-8765432109', 'MS Ortho, MBBS', 'Orthopedics'),
('Dr. Priya Sharma', '789 Wellness Road, Bangalore', '+91-7654321098', 'MD Neuro, MBBS', 'Neurology');

-- Insert sample customers
INSERT INTO customer (name, address, phone_no, pincode, age, gender, doctor_id)
VALUES 
('Amit Kumar', '101 Residential Colony, Mumbai', '+91-9988776655', 400001, 35, 'MALE', (SELECT doctor_id FROM doctor_consultation WHERE doctor_name = 'Dr. Sarah Johnson')),
('Sneha Gupta', '202 Urban Heights, Delhi', '+91-8877665544', 110001, 28, 'FEMALE', (SELECT doctor_id FROM doctor_consultation WHERE doctor_name = 'Dr. Rajesh Patel')),
('Rahul Verma', '303 Green Park, Bangalore', '+91-7766554433', 560001, 42, 'MALE', (SELECT doctor_id FROM doctor_consultation WHERE doctor_name = 'Dr. Priya Sharma'));

-- Insert sample users
INSERT INTO users (customer_id, email, password)
VALUES 
((SELECT customer_id FROM customer WHERE name = 'Amit Kumar'), 'amit@example.com', 'hashed_password_1'),
((SELECT customer_id FROM customer WHERE name = 'Sneha Gupta'), 'sneha@example.com', 'hashed_password_2'),
((SELECT customer_id FROM customer WHERE name = 'Rahul Verma'), 'rahul@example.com', 'hashed_password_3');

-- Insert sample accounts
INSERT INTO accounts (user_id, type, provider, provider_account_id)
VALUES 
((SELECT user_id FROM users WHERE email = 'amit@example.com'), 'oauth', 'google', 'google_123'),
((SELECT user_id FROM users WHERE email = 'sneha@example.com'), 'oauth', 'facebook', 'facebook_456'),
((SELECT user_id FROM users WHERE email = 'rahul@example.com'), 'oauth', 'twitter', 'twitter_789');

-- Insert sample sessions
INSERT INTO sessions (session_token, user_id, expires)
VALUES 
('token_amit', (SELECT user_id FROM users WHERE email = 'amit@example.com'), '2025-03-16 23:59:59'),
('token_sneha', (SELECT user_id FROM users WHERE email = 'sneha@example.com'), '2025-03-16 23:59:59'),
('token_rahul', (SELECT user_id FROM users WHERE email = 'rahul@example.com'), '2025-03-16 23:59:59');

-- Insert sample medicine shops
INSERT INTO medicine_shop (shop_name, shop_address, shop_phone_no)
VALUES 
('HealthPlus Pharmacy', '111 Market Street, Mumbai', '+91-9876123450'),
('CareFirst Drugstore', '222 Main Road, Delhi', '+91-8765123450'),
('MediCare Chemists', '333 Hospital Lane, Bangalore', '+91-7654123450');

-- Insert sample brands
INSERT INTO brand (brand_name, brand_location, brand_official_phone)
VALUES 
('Pfizer', 'New York, USA', '+1-212-555-1234'),
('Moderna', 'Cambridge, USA', '+1-617-555-6789'),
('Johnson & Johnson', 'New Jersey, USA', '+1-732-555-4321');

-- Insert sample products
INSERT INTO product (product_name, product_type, product_quantity, product_img_link, product_based_on_gender, 
                     product_age_group, product_price, product_commission_percent, product_mfg_date, product_exp_date, 
                     product_shop_id, product_brand_id)
VALUES 
('Paracetamol', 'Tablet', '500mg x 10', 'https://example.com/paracetamol.jpg', 'MALE', 'ADULT', 
 50.00, 5.00, '2024-12-15', '2026-12-15', 
 (SELECT shop_id FROM medicine_shop WHERE shop_name = 'HealthPlus Pharmacy'),
 (SELECT brand_id FROM brand WHERE brand_name = 'Pfizer')),
 
('Ibuprofen', 'Tablet', '400mg x 15', 'https://example.com/ibuprofen.jpg', 'FEMALE', 'ADULT', 
 75.00, 6.50, '2024-11-20', '2026-11-20', 
 (SELECT shop_id FROM medicine_shop WHERE shop_name = 'CareFirst Drugstore'),
 (SELECT brand_id FROM brand WHERE brand_name = 'Moderna')),
 
('Aspirin', 'Tablet', '300mg x 20', 'https://example.com/aspirin.jpg', 'MALE', 'ADULT', 
 60.00, 4.75, '2024-10-10', '2026-10-10', 
 (SELECT shop_id FROM medicine_shop WHERE shop_name = 'MediCare Chemists'),
 (SELECT brand_id FROM brand WHERE brand_name = 'Johnson & Johnson'));

-- Insert sample carts
INSERT INTO cart (customer_id, delivery_time)
VALUES 
((SELECT customer_id FROM customer WHERE name = 'Amit Kumar'), '14:00:00'),
((SELECT customer_id FROM customer WHERE name = 'Sneha Gupta'), '16:30:00'),
((SELECT customer_id FROM customer WHERE name = 'Rahul Verma'), '18:00:00');

-- Insert sample cart items
INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES 
((SELECT cart_id FROM cart WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Amit Kumar')),
 (SELECT product_id FROM product WHERE product_name = 'Paracetamol'), 2),
 
((SELECT cart_id FROM cart WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Sneha Gupta')),
 (SELECT product_id FROM product WHERE product_name = 'Ibuprofen'), 1),
 
((SELECT cart_id FROM cart WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Rahul Verma')),
 (SELECT product_id FROM product WHERE product_name = 'Aspirin'), 3);

-- Insert sample orders
INSERT INTO order_table (customer_id, total_amount, order_status, shipping_address, billing_address, shipping_method)
VALUES 
((SELECT customer_id FROM customer WHERE name = 'Amit Kumar'), 100.00, 'pending',
 '101 Residential Colony, Mumbai', '101 Residential Colony, Mumbai', 'Standard Delivery'),
 
((SELECT customer_id FROM customer WHERE name = 'Sneha Gupta'), 75.00, 'pending',
 '202 Urban Heights, Delhi', '202 Urban Heights, Delhi', 'Express Delivery'),
 
((SELECT customer_id FROM customer WHERE name = 'Rahul Verma'), 180.00, 'pending',
 '303 Green Park, Bangalore', '303 Green Park, Bangalore', 'Same Day Delivery');

-- Insert sample payments
INSERT INTO payment (order_id, transaction_id, total_price, payment_method, payment_status, customer_id)
VALUES 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Amit Kumar')),
 'TXN123456', 100.00, 'Credit Card', 'pending', 
 (SELECT customer_id FROM customer WHERE name = 'Amit Kumar')),
 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Sneha Gupta')),
 'TXN234567', 75.00, 'Debit Card', 'pending', 
 (SELECT customer_id FROM customer WHERE name = 'Sneha Gupta')),
 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Rahul Verma')),
 'TXN345678', 180.00, 'UPI', 'pending', 
 (SELECT customer_id FROM customer WHERE name = 'Rahul Verma'));

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, price_per_unit)
VALUES 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Amit Kumar')),
 (SELECT product_id FROM product WHERE product_name = 'Paracetamol'), 2, 50.00),
 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Sneha Gupta')),
 (SELECT product_id FROM product WHERE product_name = 'Ibuprofen'), 1, 75.00),
 
((SELECT order_id FROM order_table WHERE customer_id = (SELECT customer_id FROM customer WHERE name = 'Rahul Verma')),
 (SELECT product_id FROM product WHERE product_name = 'Aspirin'), 3, 60.00);

-- Insert sample wishlist items
INSERT INTO wishlist (customer_id, product_id)
VALUES 
((SELECT customer_id FROM customer WHERE name = 'Amit Kumar'),
 (SELECT product_id FROM product WHERE product_name = 'Ibuprofen')),
 
((SELECT customer_id FROM customer WHERE name = 'Sneha Gupta'),
 (SELECT product_id FROM product WHERE product_name = 'Aspirin')),
 
((SELECT customer_id FROM customer WHERE name = 'Rahul Verma'),
 (SELECT product_id FROM product WHERE product_name = 'Paracetamol'));
