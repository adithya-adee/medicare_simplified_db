-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUM TYPES FOR STATUS FIELDS
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- PRIMARY ENTITIES

-- DOCTOR CONSULTATION TABLE
CREATE TABLE doctor_consultation (
    doctor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_name VARCHAR(50) NOT NULL,
    doctor_address VARCHAR(250),
    doctor_phone_no VARCHAR(15),
    doctor_qualification VARCHAR(100) NOT NULL,
    doctor_specialization VARCHAR(25) NOT NULL
);

-- CUSTOMER TABLE
CREATE TABLE customer (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    address VARCHAR(250) NOT NULL,
    phone_no VARCHAR(15),
    pincode INTEGER NOT NULL CHECK (pincode BETWEEN 100001 AND 999998),
    age INTEGER NOT NULL CHECK(age BETWEEN 1 AND 149),
    gender VARCHAR(7) CHECK(gender IN ('MALE', 'FEMALE', 'OTHER')),
    doctor_id UUID REFERENCES doctor_consultation(doctor_id) ON DELETE SET NULL
);

-- NEXTAUTH TABLES
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID UNIQUE REFERENCES customer(customer_id) ON DELETE CASCADE,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(255) NOT NULL,
    provider VARCHAR(255) NOT NULL,
    provider_account_id VARCHAR(255) NOT NULL,
    refresh_token TEXT,
    access_token TEXT,
    expires_at BIGINT,
    token_type VARCHAR(255),
    scope VARCHAR(255),
    id_token TEXT,
    session_state VARCHAR(255),
    UNIQUE(provider, provider_account_id)
);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_token VARCHAR(255) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    expires TIMESTAMP NOT NULL
);

CREATE TABLE verification_tokens (
    identifier VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires TIMESTAMP NOT NULL,
    PRIMARY KEY (identifier, token)
);

-- MEDICINE SHOP TABLE
CREATE TABLE medicine_shop (
    shop_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_name VARCHAR(100) NOT NULL,
    shop_address VARCHAR(250) NOT NULL,
    shop_phone_no VARCHAR(15)
);

-- BRAND TABLE
CREATE TABLE brand (
    brand_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_name VARCHAR(50) NOT NULL,
    brand_location VARCHAR(50),
    brand_official_phone VARCHAR(15)
);

-- DEPENDENT ENTITIES

-- PRODUCT TABLE
CREATE TABLE product (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_name VARCHAR(100) NOT NULL,
    product_type VARCHAR(25) NOT NULL,
    product_quantity VARCHAR(20) NOT NULL,
    product_img_link VARCHAR(1000),
    product_based_on_gender VARCHAR(7) CHECK(product_based_on_gender IN ('MALE','FEMALE','OTHER')),
    product_age_group VARCHAR(20) CHECK(product_age_group IN ('INFANT','CHILDREN','ADULT','ANY')),
    product_price NUMERIC(10,2) CHECK(product_price > 0),
    product_commission_percent NUMERIC(5,2) CHECK(product_commission_percent >= 0),
    product_mfg_date DATE,
    product_exp_date DATE CHECK (product_exp_date > product_mfg_date),
    product_shop_id UUID REFERENCES medicine_shop(shop_id) ON DELETE CASCADE,
    product_brand_id UUID REFERENCES brand(brand_id) ON DELETE CASCADE
);

-- CART TABLE
CREATE TABLE cart (
    cart_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID UNIQUE REFERENCES customer(customer_id) ON DELETE CASCADE,
    delivery_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CART_ITEMS TABLE
CREATE TABLE cart_items (
    cart_id UUID REFERENCES cart(cart_id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(product_id) ON DELETE CASCADE,
    quantity INT CHECK (quantity > 0),
    PRIMARY KEY (cart_id, product_id)
);

-- ORDER TABLE 
CREATE TABLE order_table (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customer(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10,2),
    order_status order_status NOT NULL DEFAULT 'pending',
    shipping_address VARCHAR(250),
    billing_address VARCHAR(250),
    shipping_method VARCHAR(50)
);

-- PAYMENT TABLE FOR RAZORPAY INTEGRATION
CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES order_table(order_id) ON DELETE CASCADE,
    transaction_id VARCHAR(50) UNIQUE,
    total_price NUMERIC(10,2),
    payment_method VARCHAR(50),
    payment_status payment_status NOT NULL DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    coupon_applied BOOLEAN DEFAULT FALSE,
    customer_id UUID REFERENCES customer(customer_id),
    razorpay_order_id VARCHAR(255),
    razorpay_payment_id VARCHAR(255),
    razorpay_signature VARCHAR(255)
);

-- ORDER ITEMS TABLE
CREATE TABLE order_items (
    order_id UUID REFERENCES order_table(order_id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(product_id) ON DELETE SET NULL,
    quantity INT CHECK (quantity > 0),
    price_per_unit NUMERIC(10,2),
    PRIMARY KEY (order_id, product_id)
);

-- WISHLIST TABLE
CREATE TABLE wishlist (
    customer_id UUID REFERENCES customer(customer_id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(product_id) ON DELETE CASCADE,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, product_id)
);

-- INDEXES (For Scalability & Performance)
CREATE INDEX idx_customer_phone ON customer(phone_no);
CREATE INDEX idx_product_name ON product(product_name);
CREATE INDEX idx_product_type ON product(product_type);
CREATE INDEX idx_product_price ON product(product_price);
CREATE INDEX idx_order_customer ON order_table(customer_id);
CREATE INDEX idx_order_date ON order_table(order_date);
CREATE INDEX idx_order_status ON order_table(order_status);
CREATE INDEX idx_payment_customer ON payment(customer_id);
CREATE INDEX idx_payment_order ON payment(order_id);
CREATE INDEX idx_payment_status ON payment(payment_status);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);

-- RLS Policies for Supabase Authentication (example for the users table)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own data" ON users FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own data" ON users FOR UPDATE USING (auth.uid() = user_id);