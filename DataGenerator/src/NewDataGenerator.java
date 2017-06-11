import java.sql.Connection;
import java.util.HashMap;
import java.util.Random;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.text.SimpleDateFormat;
import java.sql.*;
import java.util.*;

public class NewDataGenerator {
  static int noOfCategories;
  static int noOfProducts;
  static int noOfCustomers;
  static int noOfSales;
  static Connection con = null;
  static int batchSize = 1000;
  static Random rand = new Random();
  static String[] statearray = {"AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL",
                "IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ",
                "NM","NV","NY","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT","VA","VI","VT",
                "WA","WI","WV","WY"};
  
  private static String DROP_VIEW = "drop view if exists precomputed;";
  private static String DROP_TABLES = "DROP TABLE items, carts, product, categories, users ";
  
  private static String CREATE_USER = "CREATE TABLE USERS ( ID SERIAL PRIMARY KEY, NAME TEXT UNIQUE NOT NULL, "
    +"AGE INTEGER NOT NULL, "
    +"ROLE TEXT NOT NULL,"
    +"STATE TEXT NOT NULL);";
  
  private static String CREATE_CATEGORIES = "CREATE TABLE CATEGORIES( CATEGORY_ID SERIAL PRIMARY KEY, "
    +"CATEGORY_NAME TEXT UNIQUE NOT NULL, "
    +"DESCRIPTION TEXT NOT NULL);";
  
  private static String CREATE_PRODUCT = "CREATE TABLE PRODUCT( SKU TEXT PRIMARY KEY, "
    +"PRODUCT_NAME TEXT NOT NULL, "
    +"CATEGORY_NAME TEXT REFERENCES CATEGORIES(CATEGORY_NAME) NOT NULL, "
    +"PRICE DECIMAL(9,2) NOT NULL, "
    +"PRODUCT_ID SERIAL NOT NULL);";
  
  private static String CREATE_CARTS = "CREATE TABLE CARTS( ID SERIAL PRIMARY KEY, "
    +"NAME TEXT REFERENCES USERS(NAME) NOT NULL, "
    +"TOTAL_PRICE DECIMAL(9,2), "
    +"PURCHASE_DATE DATE);";
  
  private static String CREATE_ITEMS = "CREATE TABLE ITEMS( PID SERIAL PRIMARY KEY, "
    +"ID SERIAL REFERENCES CARTS(ID), "
    +"SKU TEXT REFERENCES PRODUCT(SKU), "
    +"QTY INT NOT NULL, "
    +"PRICE DECIMAL(9,2) NOT NULL);";
  
  private static String INSERT_USERS = "INSERT INTO USERS(NAME, AGE, ROLE, STATE) VALUES(?,"
      + "25,"
      + " 'customer', "
      + "?); ";
  private static String INSERT_CATEGORIES = "INSERT INTO CATEGORIES(category_name, description) VALUES(?, ?) ";
  private static String INSERT_PRODUCT = "INSERT INTO PRODUCT(sku, product_name, CATEGORY_NAME, PRICE) VALUES(?, ?,?,?)";
  private static String INSERT_CARTS = "INSERT INTO CARTS(NAME, TOTAL_PRICE, PURCHASE_DATE) VALUES(?, ?, ?) ";
  private static String INSERT_ITEMS = "INSERT INTO ITEMS(id, SKU, QTY, PRICE) VALUES(?, ?, ?, ?)";
  
  int maxCustId = 0;
  int maxCatId = 0;
  int maxProdId = 0;
  
  static HashMap<String, Integer> productPrices = null;
  
  public static void createConnection(String host, String port, String sid, String username, String password) {
    try { 
      Class.forName("org.postgresql.Driver");
      con = DriverManager.getConnection("jdbc:postgresql://" + host + ":" + port + "/" + sid, username, password);
      System.out.println("Connection created successfully!!");
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  public static void closeConnection() {
    try {
      if(con != null) {
        con.close();
        System.out.println("Connection closed successfully!!");
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  private static void assertNum(int x) throws Exception {
    if(x <= 0) {
      throw new Exception("Negative number provided!!");
    }
  }
  
  private static void resetTablesSequences() {
    System.out.println("Resetting Tables");
    Statement stmt = null;
    try {
      stmt = con.createStatement();
      stmt.executeUpdate(DROP_VIEW);
      stmt.executeUpdate(DROP_TABLES);
      stmt.executeUpdate(CREATE_USER);
      stmt.executeUpdate(CREATE_CATEGORIES);
      stmt.executeUpdate(CREATE_PRODUCT);
      stmt.executeUpdate(CREATE_CARTS);
      stmt.executeUpdate(CREATE_ITEMS);
      
      System.out.println("Tables reset done");
    } catch(Exception e) {
      System.out.println("Tables reset failed!!");
      e.printStackTrace();
      System.exit(0);
    } finally {
      try {
        if(stmt != null) {
          stmt.close();
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  //"INSERT INTO USERS(NAME, AGE, ROLE, STATE) VALUES(?,25,'Customer',?)";
  private static void insertCustomers() {
    System.out.println("Inserting Customers");
    PreparedStatement ptst = null;
    try {
      int noOfRows = 0;
      int stateId=1;
      ptst = con.prepareStatement(INSERT_USERS);
      while(noOfRows < noOfCustomers) {
        ptst.setString(1, "CUST_"+noOfRows);
        stateId = rand.nextInt(51);
        ptst.setString(2, statearray[stateId]);
        ptst.addBatch();
        noOfRows++;
        
        if(noOfRows % batchSize == 0) {
          ptst.executeBatch();
        }
        
      }
      ptst.executeBatch();
      System.out.println(noOfCustomers + " customers inserted successfully");
    } catch(Exception e) {
      System.out.println("Insert Customers failed!!");
      e.printStackTrace();
      System.exit(0);
    } finally {
      try {
        if(ptst != null) {
          ptst.close();
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  //"INSERT INTO CATEGORIES(category_name, description) VALUES(?, ?) ";
  private static void insertCategories() {
    System.out.println("Inserting Categories");
    PreparedStatement ptst = null;
    try {
      int noOfRows = 0;
      ptst = con.prepareStatement(INSERT_CATEGORIES);
      while(noOfRows < noOfCategories) {
        ptst.setString(1, "CAT_"+noOfRows);
        ptst.setString(2, "CAT_DESCRIPTION_"+noOfRows);
        ptst.addBatch();
        noOfRows++;
        
        if(noOfRows % batchSize == 0) {
          ptst.executeBatch();
        }
        
      }
      ptst.executeBatch();
      System.out.println(noOfCategories + " categories inserted successfully");
    } catch(Exception e) {
      System.out.println("Insert Categories failed!!");
      e.printStackTrace();
      System.exit(0);
    } finally {
      try {
        if(ptst != null) {
          ptst.close();
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  //"INSERT INTO product(sku, product_name, CATEGORY_NAME, PRICE) ";
  private static void insertProducts() {
    System.out.println("Inserting Products");
    PreparedStatement ptst = null;
    try {
      int noOfRows = 0;
      String categoryId;
      int price = 0;
      productPrices = new HashMap<String, Integer>();
      ptst = con.prepareStatement(INSERT_PRODUCT);
      while(noOfRows < noOfProducts) {
        ptst.setString(1, "SKU_1_"+noOfRows);
        ptst.setString(2, "PROD_"+noOfRows);
        price = (rand.nextInt(1000)+1);
        ptst.setInt(4, price);
        categoryId = "CAT_"+rand.nextInt(noOfCategories);
        ptst.setString(3, categoryId);
        
        ptst.addBatch();
        
        productPrices.put("PROD_"+noOfRows, price);
        noOfRows++;
        
        if(noOfRows % batchSize == 0) {
          ptst.executeBatch();
        }
        
      }
      ptst.executeBatch();
      System.out.println(noOfProducts + " products inserted successfully");
    } catch(Exception e) {
      System.out.println("Insert Products failed!!");
      e.printStackTrace();
      System.exit(0);
    } finally {
      try {
        if(ptst != null) {
          ptst.close();
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  //"INSERT INTO CARTS(NAME, TOTAL_PRICE, PURCHASE_DATE) VALUES(?, ?, ?) ";
  private static void insertSales() {
	java.util.Date dNow = new java.util.Date();
	SimpleDateFormat ft = new SimpleDateFormat("yyyy/MM/dd");
	java.sql.Date sqlStartDate = new java.sql.Date(dNow.getTime());
    System.out.println("Inserting Sales");
    PreparedStatement ptst = null;
    batchSize = 10000;
    try {
      int noOfRows = 0;
      String personId;
      ptst = con.prepareStatement(INSERT_CARTS);
      while(noOfRows < noOfSales) {
        personId = "CUST_"+rand.nextInt(noOfCustomers);
        ptst.setString(1, personId);
        ptst.setDouble(2, 1.0);
        ptst.setDate(3, sqlStartDate);
        
        ptst.addBatch();
        noOfRows++;
        
        if(noOfRows % batchSize == 0) {
          ptst.executeBatch();
        }
        
      }
      ptst.executeBatch();
      ptst.close();
      
      noOfRows = 1;
      int totalRows = 0;
      //"INSERT INTO ITEMS(id, SKU, QTY, PRICE) VALUES(?, ?, ?, ?)";
      ptst = con.prepareStatement(INSERT_ITEMS);
      while(noOfRows <= noOfSales) {
        int noOfProductsInCart = rand.nextInt(10)+1;
        int products = 0;
        int prodid=1;
        String skuid;
        int quantity = 1;
        int productPrice = 1;
        while(products < noOfProductsInCart) {
          ptst.setInt(1, noOfRows);
          prodid=rand.nextInt(noOfProducts);
          skuid = "SKU_1_"+prodid;
          ptst.setString(2, skuid);
          quantity = rand.nextInt(100)+1;
          productPrice = productPrices.get("PROD_"+prodid);
          ptst.setInt(3, quantity);
          ptst.setDouble(4, quantity*productPrice);
          
          ptst.addBatch();
          products++;
          totalRows++;
          
          if(totalRows % batchSize == 0) {
            ptst.executeBatch();
          }
        }
        ptst.executeBatch();
        noOfRows++;
      }
      
      System.out.println(noOfSales + " sales inserted successfully");
    } catch(Exception e) {
      System.out.println("Insert Sales failed!!");
      e.printStackTrace();
      System.exit(0);
    } finally {
      try {
        if(ptst != null) {
          ptst.close();
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  public static void main(String[] args) {
    Scanner s = null;
    try {
      s = new Scanner(System.in);
      
      System.out.println("DB Connection details");
      //System.out.println("Provide the DB Host : ");
      String host = "localhost";
      
      //System.out.println("Provide the DB Port : ");
      String port = "5432";
      
      //System.out.println("Provide the DB Name : ");
      String sid = "Shopping_Application";
      
      //System.out.println("Provide the Username : ");
      String username = "postgres";
      
      //System.out.println("Provide the Password : ");
      String password = "7124804";
      
      createConnection(host, port, sid, username, password);
      System.out.println("");
      try{
        System.out.println("Provide Data Generator Inputs");
        System.out.println("Provide the number of Customers to be created : ");
        noOfCustomers = s.nextInt();
        assertNum(noOfCustomers);
        
        System.out.println("Provide the number of Categories to be created : ");
        noOfCategories = s.nextInt();
        assertNum(noOfCategories);
        
        System.out.println("Provide the number of Products to be created : ");
        noOfProducts = s.nextInt();
        assertNum(noOfProducts);
        
        System.out.println("Provide the number of Sales to be created : ");
        noOfSales = s.nextInt();
        assertNum(noOfSales);
      } catch(Exception e) {
        System.out.println("Invalid input!!");
        e.printStackTrace();
      }
      
      con.setAutoCommit(false);
      
      resetTablesSequences();
      con.commit();
      
      insertCustomers();
      insertCategories();
      con.commit();
      
      insertProducts();
      con.commit();
      
      insertSales();
      con.commit();
      
    } catch(Exception e) {
      e.printStackTrace();
      try {
        if(con != null) {
          con.rollback();
        }
      } catch(Exception e1) {
        e1.printStackTrace();
      }
    } finally {
      closeConnection();
    }
  }
}
