-- Yize / sunnyxorange migration: remaining erp bill + ship-list tables
-- Date: 2026-09-28 (Asia/Shanghai)
-- Source: entity-faithful DDL from qihang-oms Java entities + MyBatis mapper XML
--   (ErpBillShipment, ErpBillShopAccounts, ErpBillShopOrder, OOrderShipList, OOrderShipListItem)
--   Official CREATE not found in zeasin/qihang-cb-erp docs/qihang-cb-erp.sql @ 92899b4
-- Notes:
--   * No AppKeys / shop tokens / live API data
--   * IF NOT EXISTS for safe re-apply
--   * utf8mb4 / InnoDB / ROW_FORMAT=DYNAMIC to match seed style
--   * Column types follow mapper jdbcType (DECIMAL/TIMESTAMP/DATE) over String fields in entity

-- ===== erp_bill_shipment =====
CREATE TABLE IF NOT EXISTS `erp_bill_shipment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单号',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `type` int DEFAULT NULL COMMENT '账单类型1自己发货2供应商发货',
  `supplier_id` bigint DEFAULT NULL COMMENT '供应商id',
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '供应商名称',
  `date` date DEFAULT NULL COMMENT '日期',
  `ship_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流公司',
  `ship_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流单号',
  `amount` decimal(12,2) DEFAULT NULL COMMENT '应付总金额',
  `ship_amount` decimal(12,2) DEFAULT NULL COMMENT '物流费用',
  `package_amount` decimal(12,2) DEFAULT NULL COMMENT '包装费用',
  `goods_amount` decimal(12,2) DEFAULT NULL COMMENT '商品金额',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT NULL COMMENT '状态（0已生成1已结算)',
  `create_time` datetime DEFAULT NULL COMMENT '订单创建时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_supplier_id` (`supplier_id`) USING BTREE,
  KEY `idx_order_num` (`order_num`) USING BTREE,
  KEY `idx_date` (`date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='账单-发货账单表';

-- ===== erp_bill_shop_accounts =====
CREATE TABLE IF NOT EXISTS `erp_bill_shop_accounts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int DEFAULT NULL COMMENT '账单类型1支出2收入',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `trade_time` datetime DEFAULT NULL COMMENT '交易时间',
  `date` date DEFAULT NULL COMMENT '日期',
  `amount` decimal(12,2) DEFAULT NULL COMMENT '应付总金额',
  `usage_scenario` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用途',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT NULL COMMENT '状态（0已生成1已结算)',
  `create_time` datetime DEFAULT NULL COMMENT '订单创建时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_date` (`date`) USING BTREE,
  KEY `idx_type` (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='店铺账目表';

-- ===== erp_bill_shop_order =====
CREATE TABLE IF NOT EXISTS `erp_bill_shop_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `shop_type` int DEFAULT NULL COMMENT '店铺类型',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单号',
  `type` int DEFAULT NULL COMMENT '1收入2支出',
  `amount` double DEFAULT NULL COMMENT '金额',
  `biz_time` datetime DEFAULT NULL COMMENT '业务时间',
  `biz_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '服务类型',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `detail` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '明细',
  `update_time` datetime DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_biz_time` (`biz_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='店铺账单';

-- ===== o_order_ship_list =====
CREATE TABLE IF NOT EXISTS `o_order_ship_list` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `shop_type` int DEFAULT NULL COMMENT '店铺类型',
  `shipper` int DEFAULT NULL COMMENT '发货方 0 仓库发货 1 供应商发货',
  `ship_supplier_id` bigint DEFAULT NULL COMMENT '发货供应商ID（0自己发货）',
  `ship_supplier` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '发货供应商',
  `order_id` bigint DEFAULT NULL COMMENT 'erp订单id',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单编号',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '收件人姓名',
  `receiver_mobile` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '收件人手机号',
  `address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '收件人地址',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '市',
  `town` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '区',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `buyer_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '买家留言信息',
  `seller_memo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '卖家留言信息',
  `ship_logistics_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流公司',
  `ship_logistics_company_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流公司code',
  `ship_logistics_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '物流单号',
  `ship_status` int DEFAULT NULL COMMENT '发货状态1：待发货，2：已发货，3已推送',
  `status` int DEFAULT NULL COMMENT '状态0待备货1备货中2备货完成3已发货',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_order_num` (`order_num`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_shipper` (`shipper`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='发货-备货表';

-- ===== o_order_ship_list_item =====
CREATE TABLE IF NOT EXISTS `o_order_ship_list_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `list_id` bigint DEFAULT NULL COMMENT '外键id',
  `shop_id` bigint DEFAULT NULL COMMENT '店铺id',
  `shop_type` int DEFAULT NULL COMMENT '店铺类型',
  `shipper` int DEFAULT NULL COMMENT '发货方 0 仓库发货 1 供应商发货',
  `ship_supplier_id` bigint DEFAULT NULL COMMENT '发货供应商ID（0自己发货）',
  `ship_supplier` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '发货供应商',
  `order_id` bigint DEFAULT NULL COMMENT 'erp订单id',
  `order_item_id` bigint DEFAULT NULL COMMENT 'erp订单itemid',
  `order_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '订单编号',
  `original_sku_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '原始订单skuid',
  `goods_id` bigint DEFAULT NULL COMMENT 'erp系统商品id',
  `sku_id` bigint DEFAULT NULL COMMENT 'erp系统商品规格id',
  `goods_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品标题',
  `goods_img` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品图片',
  `goods_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品编码',
  `sku_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品规格',
  `sku_num` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品规格编码',
  `quantity` int DEFAULT NULL COMMENT '商品数量',
  `status` int DEFAULT NULL COMMENT '状态0待备货1备货中2备货完成3已发货',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_list_id` (`list_id`) USING BTREE,
  KEY `idx_shop_id` (`shop_id`) USING BTREE,
  KEY `idx_order_id` (`order_id`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='发货-备货明细表';
