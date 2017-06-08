<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*, java.util.Random, java.util.*,java.text.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Shopping Application</title>
</head>
<body>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript">
  $(function(){
      $(".submitBtn").click(function () {
        $(".submitBtn").attr("disabled", true);
        $('#buyOrders').submit();
      });
    });
</script>
  <% if(session.getAttribute("role") != null) { %>
    <% if(request.getParameter("totalOrder") != null && !request.getParameter("totalOrder").equals("")) {
      try {
        if(Integer.parseInt(request.getParameter("totalOrder")) <= 0 ) {
          request.setAttribute("message", "Order value is negative. Please provide a positive integer");
          request.setAttribute("error", true);
        } else {
          Class.forName("org.postgresql.Driver");
          Connection con=null;
          con = DriverManager.getConnection(
            "jdbc:postgresql://localhost/Shopping_Application?" +
            "user=postgres&password=7124804");
          con.setAutoCommit(false);
          String INSERT_SHOPPING_CART = "INSERT INTO carts(name, total_price, purchase_date) VALUES( ?, ?,? ) ";
          String INSERT_PRODUCTS_IN_CART = "INSERT INTO items(id, sku,qty, price) VALUES(?, ?, ?, ?)";
          String GET_RANDOM_PERSON = "SELECT id,name FROM users OFFSET floor(random()* (select count(*) from users)) LIMIT 1";
          String GET_RANDOM_5_PRODUCTS = "SELECT product_id,sku, price, product_name FROM product OFFSET floor(random()* (select count(*) from product)) LIMIT 5";
          Random rand = new Random();
          int noOfSales = Integer.parseInt(request.getParameter("totalOrder"));
          int batchSize = 10000;
          int personId = 0;
          String personName=null;
          String productSKU=null;
          String productName=null;
          int noOfRows = 0;
          int productId = 0;
          int productPrice = 0;
          int quantity = 0;     
          PreparedStatement shoppingCartPtst = null, productsCartPtst  = null, logPtst=null;
          Statement personSt = null, productSt = null;
          ArrayList<Integer> cartIds = new ArrayList<Integer>();
          try {
            shoppingCartPtst = con.prepareStatement(INSERT_SHOPPING_CART, Statement.RETURN_GENERATED_KEYS);
            logPtst = con.prepareStatement("INSERT into log(cart_id,product_name,price) VALUES (?,?,?) ");
            productsCartPtst = con.prepareStatement(INSERT_PRODUCTS_IN_CART);
            personSt = con.createStatement();
            productSt = con.createStatement();
            
            for(int i=0;i<noOfSales;i++) {
              ResultSet personRs = personSt.executeQuery(GET_RANDOM_PERSON);
              if(personRs.next()) {
                personName = personRs.getString("name");
              }

              personRs.close();
              
              shoppingCartPtst.setString(1, personName);
              shoppingCartPtst.setDouble(2, 1.00);
              java.util.Date dNow = new java.util.Date();
              SimpleDateFormat ft = new SimpleDateFormat("yyyy/MM/dd");
              java.sql.Date sqlStartDate = new java.sql.Date(dNow.getTime());
              shoppingCartPtst.setDate(3, sqlStartDate);
              
              
              shoppingCartPtst.addBatch();
              noOfRows++;
              
              if(noOfRows % batchSize == 0) {
                shoppingCartPtst.executeBatch();              
                ResultSet cartRs = shoppingCartPtst.getGeneratedKeys();
                while(cartRs.next()) {
                  cartIds.add(cartRs.getInt(1));
                }
                cartRs.close();
              }
              
            }
            shoppingCartPtst.executeBatch();
            ResultSet cartRs = shoppingCartPtst.getGeneratedKeys();
            while(cartRs.next()) {
              cartIds.add(cartRs.getInt(1));
            }
            cartRs.close();
            shoppingCartPtst.close();
            
            int totalRows = 0;
            for(int i=0;i<noOfSales;i++) {
              ResultSet productRs = productSt.executeQuery(GET_RANDOM_5_PRODUCTS);
              while(productRs.next()) {
                productsCartPtst.setInt(1, cartIds.get(i));
                logPtst.setInt(1, cartIds.get(i));
                productSKU = productRs.getString("sku");
                productName=productRs.getString("product_name");
                productsCartPtst.setString(2, productSKU);
                logPtst.setString(2, productName);
                
                quantity = rand.nextInt(10)+1;
                productsCartPtst.setInt(3, quantity);
                productPrice = productRs.getInt("price");
                productPrice=productPrice*quantity;
                productsCartPtst.setInt(4, productPrice);
                logPtst.setInt(3, productPrice);
                
                productsCartPtst.addBatch();
                logPtst.addBatch();
                totalRows++;
                
                if(totalRows % batchSize == 0) {
                  logPtst.executeBatch();
                  productsCartPtst.executeBatch();
                  
                }
              }
              logPtst.executeBatch();
              productsCartPtst.executeBatch();
            }
            con.commit();
            request.setAttribute("message", "Orders inserted successfully");
            request.setAttribute("error", false); 
          } catch(Exception e) {
            con.rollback();
            e.printStackTrace();
            request.setAttribute("message", e);
            request.setAttribute("error", true);
          } finally {
            try { 
              if(shoppingCartPtst != null) {
                shoppingCartPtst.close();
              }
              if(productsCartPtst != null) {
                productsCartPtst.close();
              }
              if(personSt != null) {
                personSt.close();
              }
              if(productSt != null) {
                productSt.close();
              }
            } catch(Exception e1) {
              e1.getStackTrace();
              request.setAttribute("message", e1);
              request.setAttribute("error", true);
            }
            if(con != null) {
              con.close();
            }
          }
        }
      }catch(Exception e2) {
        e2.printStackTrace();
      }
    }
    %>
    <% if(request.getAttribute("error") != null && (boolean)request.getAttribute("error")) { %>
      <h3 style="color:red;">Data Modification Failure</h3>
      <h4 style="color:red;"><%= request.getAttribute("message").toString() %></h4>
      <% request.setAttribute("message", null);
        request.setAttribute("error", false);
    } 
      
    if(request.getAttribute("message")!= null && !(boolean)request.getAttribute("error")) { %>
      <h4 style="color:green;"><%= request.getAttribute("message").toString() %></h4>
      <% 
      request.setAttribute("message", null);
      request.setAttribute("error", false);
    }
    %>
    <table cellspacing="5">
      <tr>
        <td valign="top"> </td>
        <td></td>
        <td>
          <h3>Hello <%= session.getAttribute("personName") %></h3>
        <h3>Buy N Orders</h3>
        <p> Provide number of orders to be inserted. It will insert 'N' carts and '5' products for each cart, of random quantity between 1 and 10. Customers and Products are picked up randomly from the table </p> 
        <form method="GET" action="buyOrders.jsp" id="buyOrders">
          Enter number of Orders : <input type="text" name="totalOrder" required=true/>
          <input type="submit" value="Buy" class="submitBtn"/>
        </form>
        <br/>
        </td>
      </tr>
    </table>
  <%     
  }
  else { %>
      <h3>Please <a href = "./login.jsp">login</a> before viewing the page</h3>
  <% } %>
</body>
</html>