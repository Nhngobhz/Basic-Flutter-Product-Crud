ALTER DATABASE ecom CHARACTER 
SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE users (
	id INT PRIMARY KEY AUTO_INCREMENT,
	username VARCHAR ( 100 ),
	email VARCHAR ( 150 ) UNIQUE NOT NULL,
	PASSWORD VARCHAR ( 255 ) NOT NULL,
	otp VARCHAR ( 10 ),
	otp_expiry DATETIME,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);
CREATE TABLE categories ( id INT PRIMARY KEY AUTO_INCREMENT, NAME VARCHAR ( 255 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci, description VARCHAR ( 500 ), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE products (
	id INT PRIMARY KEY AUTO_INCREMENT,
	NAME VARCHAR ( 255 ) CHARACTER 
	SET utf8mb4 COLLATE utf8mb4_unicode_ci,
	description VARCHAR ( 500 ),
	category_id INT,
	price DECIMAL ( 10, 2 ),
	image_url VARCHAR ( 255 ),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY ( category_id ) REFERENCES categories ( id ) 
);
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 1, 'Iced Coffee', 'Refreshing cold coffee beverages, perfect for a hot day.', '2026-02-26 08:47:14' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 2, 'Hot Coffee', 'Warm, aromatic coffee to start your day or cozy up.', '2026-02-26 08:47:30' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 3, 'Iced Drink', 'Chilled beverages and juices to cool you down.', '2026-02-26 08:48:04' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 4, 'Hot Drink', 'Comforting warm drinks like tea, cocoa, or lattes', '2026-02-26 08:48:27' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 5, 'Frappuccino', 'Blended icy coffee treats with flavors and toppings', '2026-02-26 08:48:44' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 6, 'Food & Snacks', 'Tasty bites, pastries, and light snacks for anytime', '2026-02-26 08:49:14' );
INSERT INTO `categories` ( `id`, `name`, `description`, `created_at` )
VALUES
	( 7, 'ផ្លែឈើ', 'ផ្លែឈើ', '2026-02-26 09:27:46' );
	
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 1, 'Iced Americano', 'Strong espresso over ice', 1, 2.50, '/uploads/images/product-1772070663982-57214.jpg', '2026-02-26 08:51:03' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 2, 'Iced Latte', 'Espresso with milk served cold', 1, 3.00, '/uploads/images/product-1772070707009-394491.jpg', '2026-02-26 08:51:47' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 3, 'Iced Cappuccino', 'Creamy foam over chilled espresso', 1, 3.20, '/uploads/images/product-1772070741761-119.png', '2026-02-26 08:52:21' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 4, 'Iced Mocha', 'Chocolate and espresso over ice', 1, 3.50, '/uploads/images/product-1772070786393-935856.jpg', '2026-02-26 08:53:06' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 5, 'Iced Caramel Macchiato', 'Sweet caramel with espresso and milk', 1, 3.70, '/uploads/images/product-1772070863200-391657.jpg', '2026-02-26 08:53:50' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 6, 'Espresso', 'Classic strong coffee shot', 2, 2.00, '/uploads/images/product-1772071384448-263566.jpg', '2026-02-26 09:03:04' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 7, 'Hot Latte', 'Smooth espresso with steamed milk', 2, 2.80, '/uploads/images/product-1772071425696-92425.jpg', '2026-02-26 09:03:45' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 8, 'Cappuccino', 'Espresso with milk foam', 2, 4.00, '/uploads/images/product-1772071451578-294593.jpg', '2026-02-26 09:04:11' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 9, 'Hot Mocha', 'Chocolate-infused hot coffee', 2, 3.30, '/uploads/images/product-1772071510675-414956.jpg', '2026-02-26 09:05:10' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 10, 'Flat White', 'Espresso with velvety milk', 2, 3.20, '/uploads/images/product-1772071542880-785561.jpg', '2026-02-26 09:05:42' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 11, 'Iced Lemon Tea', 'Refreshing lemon-flavored iced tea', 3, 1.50, '/uploads/images/product-1772071620164-537285.jpg', '2026-02-26 09:07:00' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 12, 'Iced Peach Tea', 'Sweet peach iced tea', 3, 1.70, '/uploads/images/product-1772071667899-911312.jpg', '2026-02-26 09:07:47' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 13, 'Iced Green Tea', 'Chilled green tea with mint', 3, 1.80, '/uploads/images/product-1772071708604-70156.jpg', '2026-02-26 09:08:28' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 14, 'Iced Mango Tea', 'Tropical mango iced tea', 3, 2.00, '/uploads/images/product-1772071741480-339400.jpg', '2026-02-26 09:09:01' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 15, 'Iced Passionfruit Tea', 'Tangy passionfruit over ice', 3, 2.10, '/uploads/images/product-1772071773259-611153.jpg', '2026-02-26 09:09:33' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 16, 'Hot Chocolate', 'Rich chocolate drink', 4, 2.50, '/uploads/images/product-1772071833236-431964.jpg', '2026-02-26 09:10:33' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 17, 'Hot Green Tea', 'Traditional warm green tea', 4, 2.00, '/uploads/images/product-1772071894454-943260.jpg', '2026-02-26 09:11:34' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 18, 'Chai Latte', 'Indian tea with milk', 4, 2.80, '/uploads/images/product-1772071943821-562569.jpg', '2026-02-26 09:12:23' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 19, 'Herbal Tea', 'Calming herbal infusion', 4, 2.20, '/uploads/images/product-1772071969166-290145.jpg', '2026-02-26 09:12:49' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 20, 'Hot Lemon Honey', 'Lemon and honey warm drink', 4, 2.30, '/uploads/images/product-1772071999320-11508.jpg', '2026-02-26 09:13:19' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 21, 'Mocha Frappuccino', 'Blended chocolate and coffee', 5, 3.50, '/uploads/images/product-1772072047762-474917.jpg', '2026-02-26 09:14:07' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 22, 'Caramel Frappuccino', 'Sweet caramel blended drink', 5, 3.70, '/uploads/images/product-1772072072078-259152.jpg', '2026-02-26 09:14:32' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 23, 'Vanilla Frappuccino', 'Smooth vanilla iced blend', 5, 3.30, '/uploads/images/product-1772072097621-54673.jpg', '2026-02-26 09:14:57' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 24, 'Matcha Frappuccino', 'Green tea blended with milk', 5, 3.60, '/uploads/images/product-1772072129334-435622.jpg', '2026-02-26 09:15:29' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 25, 'Strawberry Frappuccino', 'Sweet strawberry blended drink', 5, 3.80, '/uploads/images/product-1772072168969-517038.jpg', '2026-02-26 09:16:08' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 26, 'Croissant', 'Buttery flaky pastry', 6, 2.50, '/uploads/images/product-1772072213789-321678.jpg', '2026-02-26 09:16:53' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 27, 'បាយឆាម្រះព្រៅ', NULL, 6, 5.00, '/uploads/images/product-1772072418701-904976.jpg', '2026-02-26 09:20:18' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 28, 'បាយឆា', NULL, 6, 4.00, '/uploads/images/product-1772072742009-499042.jpg', '2026-02-26 09:25:42' );
INSERT INTO `products` ( `id`, `name`, `description`, `category_id`, `price`, `image_url`, `created_at` )
VALUES
	( 29, 'ឪឡឹក', NULL, 7, 10.00, '/uploads/images/product-1772072936310-104872.jpg', '2026-02-26 09:28:56' );