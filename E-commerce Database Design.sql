-- E-commerce Database Schema
-- Created for Peer Group Assignment

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS product_attribute;
DROP TABLE IF EXISTS product_variation;
DROP TABLE IF EXISTS product_image;
DROP TABLE IF EXISTS product_item;
DROP TABLE IF EXISTS size_option;
DROP TABLE IF EXISTS size_category;
DROP TABLE IF EXISTS color;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS product_category;
DROP TABLE IF EXISTS brand;
DROP TABLE IF EXISTS attribute_type;
DROP TABLE IF EXISTS attribute_category;

-- Create tables (in order of dependencies)

-- Brand table
CREATE TABLE brand (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Product Category table with self-reference for hierarchical categories
CREATE TABLE product_category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES product_category(category_id) ON DELETE SET NULL
);

-- Product table
CREATE TABLE product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    brand_id INT,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES product_category(category_id) ON DELETE RESTRICT
);

-- Color table
CREATE TABLE color (
    color_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    hex_code VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Size Category table
CREATE TABLE size_category (
    size_category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Size Option table
CREATE TABLE size_option (
    size_id INT PRIMARY KEY AUTO_INCREMENT,
    size_category_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    measurement VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (size_category_id) REFERENCES size_category(size_category_id) ON DELETE CASCADE
);

-- Product Item table (specific variations of products that can be purchased)
CREATE TABLE product_item (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    price DECIMAL(10,2),
    SKU VARCHAR(100) UNIQUE NOT NULL,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);

-- Product Image table
CREATE TABLE product_image (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_item_id INT,
    url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    alt_text VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (product_item_id) REFERENCES product_item(item_id) ON DELETE CASCADE,
    -- Either product_id or product_item_id must be non-null, but not necessarily both
    CONSTRAINT chk_image_association CHECK (product_id IS NOT NULL OR product_item_id IS NOT NULL)
);

-- Product Variation table (connects product items with specific color and size)
CREATE TABLE product_variation (
    variation_id INT PRIMARY KEY AUTO_INCREMENT,
    product_item_id INT NOT NULL,
    color_id INT,
    size_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_item_id) REFERENCES product_item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (color_id) REFERENCES color(color_id) ON DELETE SET NULL,
    FOREIGN KEY (size_id) REFERENCES size_option(size_id) ON DELETE SET NULL,
    -- A product variation should have at least one attribute (color or size)
    CONSTRAINT chk_variation_attributes CHECK (color_id IS NOT NULL OR size_id IS NOT NULL)
);

-- Attribute Category table
CREATE TABLE attribute_category (
    attr_category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Attribute Type table
CREATE TABLE attribute_type (
    attr_type_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    data_type ENUM('text', 'number', 'boolean', 'date') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Product Attribute table
CREATE TABLE product_attribute (
    attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_item_id INT,
    attr_category_id INT NOT NULL,
    attr_type_id INT NOT NULL,
    attr_name VARCHAR(100) NOT NULL,
    attr_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (product_item_id) REFERENCES product_item(item_id) ON DELETE CASCADE,
    FOREIGN KEY (attr_category_id) REFERENCES attribute_category(attr_category_id) ON DELETE CASCADE,
    FOREIGN KEY (attr_type_id) REFERENCES attribute_type(attr_type_id) ON DELETE CASCADE,
    -- Either product_id or product_item_id must be non-null, but not necessarily both
    CONSTRAINT chk_attribute_association CHECK (product_id IS NOT NULL OR product_item_id IS NOT NULL)
);

-- Create indexes for better performance
CREATE INDEX idx_product_brand ON product(brand_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_item_product ON product_item(product_id);
CREATE INDEX idx_product_variation_color ON product_variation(color_id);
CREATE INDEX idx_product_variation_size ON product_variation(size_id);
CREATE INDEX idx_size_option_category ON size_option(size_category_id);
CREATE INDEX idx_product_attribute_category ON product_attribute(attr_category_id);
CREATE INDEX idx_product_attribute_type ON product_attribute(attr_type_id);

-- Sample data insertion to help with testing
-- Note: In a real project, you might want to create separate insert scripts

-- Insert sample brands
INSERT INTO brand (name, logo_url, description) VALUES
('Nike', 'https://example.com/logos/nike.png', 'Just Do It'),
('Apple', 'https://example.com/logos/apple.png', 'Think Different'),
('Samsung', 'https://example.com/logos/samsung.png', 'Do What You Can\'t');

-- Insert sample product categories
INSERT INTO product_category (name, parent_category_id, description) VALUES
('Electronics', NULL, 'Electronic devices and accessories'),
('Clothing', NULL, 'Fashion items and apparel'),
('Smartphones', 1, 'Mobile phones and accessories'),
('Laptops', 1, 'Portable computers'),
('T-shirts', 2, 'Casual upper body wear'),
('Sneakers', 2, 'Athletic footwear');

-- Insert sample colors
INSERT INTO color (name, hex_code) VALUES
('Black', '#000000'),
('White', '#FFFFFF'),
('Red', '#FF0000'),
('Blue', '#0000FF'),
('Gray', '#808080');

-- Insert sample size categories
INSERT INTO size_category (name, description) VALUES
('Clothing Sizes', 'Standard clothing size measurements'),
('Shoe Sizes', 'Standard shoe size measurements'),
('Electronics Sizes', 'Size classifications for electronic devices');

-- Insert sample size options
INSERT INTO size_option (size_category_id, name, measurement) VALUES
(1, 'S', 'Small - Chest 36-38 inches'),
(1, 'M', 'Medium - Chest 38-40 inches'),
(1, 'L', 'Large - Chest 40-42 inches'),
(2, '8', 'US 8 / EU 41'),
(2, '9', 'US 9 / EU 42'),
(2, '10', 'US 10 / EU 43'),
(3, '13"', '13-inch diagonal screen size'),
(3, '15"', '15-inch diagonal screen size');

-- Insert sample attribute categories
INSERT INTO attribute_category (name, description) VALUES
('Physical', 'Physical characteristics of the product'),
('Technical', 'Technical specifications'),
('Material', 'Material composition information');

-- Insert sample attribute types
INSERT INTO attribute_type (name, data_type) VALUES
('Weight', 'number'),
('Dimensions', 'text'),
('Material', 'text'),
('RAM', 'text'),
('Storage', 'text'),
('Battery Life', 'text'),
('Fabric Composition', 'text');

-- Insert sample products
INSERT INTO product (brand_id, category_id, name, base_price, description) VALUES
(2, 4, 'MacBook Pro', 1299.99, 'Powerful laptop for professionals'),
(3, 3, 'Galaxy S23', 799.99, 'Flagship smartphone with advanced camera'),
(1, 5, 'Dri-FIT T-Shirt', 35.00, 'Moisture-wicking athletic t-shirt'),
(1, 6, 'Air Force 1', 110.00, 'Classic basketball sneakers');

-- Insert sample product items
INSERT INTO product_item (product_id, price, SKU, quantity_in_stock, active) VALUES
(1, 1299.99, 'MBP-13-256-SLV', 50, true),
(1, 1499.99, 'MBP-13-512-SLV', 30, true),
(2, 799.99, 'GS23-128-BLK', 100, true),
(2, 849.99, 'GS23-128-WHT', 75, true),
(3, 35.00, 'NIKE-TS-M-BLK', 200, true),
(3, 35.00, 'NIKE-TS-L-BLK', 180, true),
(4, 110.00, 'AF1-9-WHT', 60, true),
(4, 110.00, 'AF1-10-WHT', 45, true);

-- Insert sample product variations
INSERT INTO product_variation (product_item_id, color_id, size_id) VALUES
(1, 5, 7),  -- Silver 13" MacBook
(2, 5, 8),  -- Silver 15" MacBook
(3, 1, NULL),  -- Black Galaxy S23
(4, 2, NULL),  -- White Galaxy S23
(5, 1, 2),  -- Black Medium T-shirt
(6, 1, 3),  -- Black Large T-shirt
(7, 2, 5),  -- White Size 9 Air Force 1
(8, 2, 6);  -- White Size 10 Air Force 1

-- Insert sample product images
INSERT INTO product_image (product_id, product_item_id, url, is_primary, alt_text) VALUES
(1, NULL, 'https://example.com/images/macbook-pro-main.jpg', true, 'MacBook Pro'),
(1, 1, 'https://example.com/images/macbook-pro-13-silver.jpg', false, 'MacBook Pro 13" Silver'),
(1, 2, 'https://example.com/images/macbook-pro-15-silver.jpg', false, 'MacBook Pro 15" Silver'),
(2, NULL, 'https://example.com/images/galaxy-s23-main.jpg', true, 'Samsung Galaxy S23'),
(2, 3, 'https://example.com/images/galaxy-s23-black.jpg', false, 'Samsung Galaxy S23 Black'),
(2, 4, 'https://example.com/images/galaxy-s23-white.jpg', false, 'Samsung Galaxy S23 White'),
(3, NULL, 'https://example.com/images/nike-tshirt-main.jpg', true, 'Nike Dri-FIT T-Shirt'),
(4, NULL, 'https://example.com/images/air-force-1-main.jpg', true, 'Nike Air Force 1');

-- Insert sample product attributes
INSERT INTO product_attribute (product_id, product_item_id, attr_category_id, attr_type_id, attr_name, attr_value) VALUES
(1, NULL, 2, 4, 'RAM', '8GB'),
(1, NULL, 2, 5, 'Storage', '256GB SSD'),
(1, NULL, 2, 6, 'Battery Life', 'Up to 20 hours'),
(2, NULL, 2, 5, 'Storage', '128GB'),
(2, NULL, 1, 2, 'Dimensions', '146.3 x 70.9 x 7.6 mm'),
(3, NULL, 3, 7, 'Fabric Composition', '100% Polyester'),
(3, NULL, 1, 1, 'Weight', '180g'),
(4, NULL, 3, 3, 'Material', 'Leather and Synthetic');