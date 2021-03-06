<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.util.*" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Sales Analytics</title>
    <style>
      div.container {
        width: 100%;
      }
      div.header {
        padding: 1em;
        clear: left;
        text-align: center;
      }
      div.nav {
        float: top;
        margin: 0;
        padding: 1em;
      }
      ul#nav_list li{
    	display:inline;
	  }
      div.tables {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }
      #grid {
    	width: 3820px;
    	height: 3190px;        
	  }
	  .cell {
	    outline: 5px solid lime;
    	float: left;
    	height: 20px;
   	 	width: 60px;    
	  }
	  .wide_cell {
    	float: left;
    	height: 20px;
   	 	width: 3700px;    
	  }
	  .high_cell {
    	float: left;
    	height: 3150px;
   	 	width: 60px;    
	  }
	  .supercell {
    	float: left;
    	height: 3150px;
   	 	width: 3700px;    
	  }  
	  .red {
	  	color:red;
	  }    
	  .purple {
	  	color:purple;
	  }
	  
	  
    </style>
    <script type="text/javascript">
    	function refreshPage () {
        	var page_y = document.getElementsByTagName("body")[0].scrollTop;
        	var page_x = document.getElementsByTagName("body")[0].scrollLeft;
        	window.location.href = window.location.href.split('?')[0] + '?page_y=' + page_y + '?page_x=' + page_x;
    	}
    	window.onload = function () {
        	
        	if ( window.location.href.indexOf('page_y') != -1 && window.location.href.indexOf('page_x') != -1) {
        	    var match = window.location.href.split('?')[1].split("&")[0].split("=");
        	    document.getElementsByTagName("body")[0].scrollTop = match[1];
        	}
    	}
    	
    </script>
  </head>

  <body> 
  <div class="container">
    <%
    String name=null;
    String role=null;
    try{
      if(session.getAttribute("name")!=null || !session.getAttribute("name").equals("")) {
        name=(String) session.getAttribute("name");
        }
      else{name="";}
  
      if(session.getAttribute("role")!=null || !session.getAttribute("role").equals("")) {
        role=(String) session.getAttribute("role");
        }
      else{role="";}
    }catch(Exception e){
      name="";
      role="";
    }
    if(name.equals("")){
      response.sendRedirect("/CSE135/redirectlogin");
      }
    else if(role.equals("customer") || role.equals("")) {
      response.sendRedirect("/CSE135/redirectaccess");
    }
    int rowlimit=20;
    int collimit=10;
    %>
  
    <%@ page import="java.sql.*"%>
    <%
    Connection conn=null;
    Statement stmt=null;
    Statement stmt2=null;
    Statement stmt3=null;
    Statement stmt4=null;
    Statement stmt5=null;
    
    Statement update_cell_stmnt=null;
    Statement update_state_stmnt=null;
    Statement update_prod_stmnt=null;
    Statement top_stmnt = null;
    Statement logstmt = null;
    Statement new_stmt = null;
    
    ResultSet rs1=null;
    ResultSet rs2=null;
    ResultSet rs3=null;
    ResultSet rs4=null;
    ResultSet rs5=null;
    
    ResultSet rs_log = null;
    ResultSet rs_top_fiddy=null;
    ResultSet rs_new_top_fiddy=null;
    
    ArrayList<String> catlist = new ArrayList<String>();
    String rows;
    String order;
    String action=null;
    String filter;
    String filterquery;
    String currentState=null;
    String statename = null;
    int ind=0;
    int countrow;
    int countcol;
    boolean showtable=true;
    boolean showcolbut = false;
    boolean showrowbut = false;
    
    
    action=request.getParameter("action");
    if(action!=null && action.equals("categoryfilter")){
      session.setAttribute("selectfilter", request.getParameter("filterdrop")); 
    }
    if(action!=null && action.equals("restart")){

      session.removeAttribute("selectfilter");
    }

    
    rows="state";
    order="top-k";
    try{
      if (session.getAttribute("selectfilter")!=null || !session.getAttribute("selectfilter").equals("")){
        filterquery="where p.category_name='"+(String)(session.getAttribute("selectfilter"))+"' ";
        filter=(String)(session.getAttribute("selectfilter"));
      }else {
        filter="";
        filterquery="";
      }
      if (session.getAttribute("selectfilter")!=null && session.getAttribute("selectfilter").equals("All")){
        filter="";
        filterquery="";
      }
    }catch(Exception e){
      filter="";
      filterquery="";
    }
    
    %>
    <div class="header">
      <h1>Sales Analytics</h1>
      <%
      if(name!=null && !name.equals("")){
        out.println("<h4>Hello, "+name+"!</h4>");
      }
      %>
    </div>
    <div class="nav">
      <ul id="nav_list">
        <%
        if(role.equals("owner")){
          out.println("<li><a href=\"/CSE135/categories\">Categories Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/products\">Products Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/similar_products\">Similar Products</a></li>"+
                    "<li><a href=\"/CSE135/analytics\">Sales Analytics</a></li>");
        }
        %>
        <li><a href="/CSE135/analytics">Sales Analytics</a></li>
        <li><a href="/CSE135/browsing">Product Browsing Page</a></li>
        <li><a href="/CSE135/order">Product Order Page</a></li>
        <li><a href="/CSE135/buy">Buy Shopping Cart</a></li>
        <li><a href="/CSE135/buyOrders.jsp">Buy Orders</a></li>
      </ul>
    </div>
    <!-- choose row and column -->
<%
    try{
      Class.forName("org.postgresql.Driver");
      conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost/Shopping_Application?" +
          "user=postgres&password=7124804");
      
      stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
      stmt2 = conn.createStatement();
      stmt3 = conn.createStatement();
      stmt4 = conn.createStatement();
      stmt5 = conn.createStatement();
      
      update_cell_stmnt = conn.createStatement();
      update_state_stmnt = conn.createStatement();
      update_prod_stmnt = conn.createStatement();
      top_stmnt = conn.createStatement();
      logstmt = conn.createStatement();
      new_stmt = conn.createStatement();
      %>      
      <!-- category filter -->
      <table>
        <tr>
          <td>Category Filter: </td>
          <td>
            <% 
            rs1=stmt.executeQuery("select category_name from categories");
            while(rs1.next()){
              catlist.add(rs1.getString("category_name"));
            }
            %>
            <form action="/CSE135/analytics" method="post">
              <input type="hidden" name="action" value="categoryfilter">
              <select name="filterdrop">
              <%
                if(filter.equals("")||filter.equals("All")){
                  %>
                  <option value="All">All</option>
                  <%
                  for(String check:catlist){
                    %>
                    <option value=<%=check%>><%=check%></option>
                    <%
                  }
                }else{
                  %>
                  <option value=<%=filter%>><%=filter%></option>
                  <%
                  for(String check:catlist){
                    if(!check.equals(filter)){
                    %>
                    <option value=<%=check%>><%=check%></option>
                    <%
                    }
                  }
                  %>
                  <option value="All">All</option>
                  <%
                }
              rs1.close();
              %>
              </select>
              <input type="submit" value="Filter">
            </form>
          </td>
        </tr>
      </table>
      
      <div id ="grid">

      <div class="cell">
         <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="refresh_table">
          <input type="submit" value="Refresh" onClick="refreshTable();">
        </form>
       <!--  <button onClick="refreshTable();" value="show">Refresh</button>-->
      </div>
      
      <div class="wide_cell"></div>
      
      <div class="cell">
      	<form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="refresh_table">
          <input type="submit" value="Refresh" onClick="refreshTable();">
        </form>
        <!-- <button onClick="refreshTable();" value="show">Refresh</button> -->
      </div>
      <div class="high_cell"></div>
      
      <div class="supercell">
      <!-- 2-d chart that displays report -->
      <%
      if ((!rows.equals("") && !order.equals(""))){  
        if(order.equals("top-k")){
          if (!filterquery.equals("")){
            filterquery = "and p.category_name='"+filter+"'";
          }
          
          rs_top_fiddy = top_stmnt.executeQuery("select product_name from (select product_name,sum(product_sum) as biscuit from precomputed " +
        		  "group by product_name order by biscuit desc limit 50) as foo");
          ArrayList<String> top_fiddy = new ArrayList<String>();
          while(rs_top_fiddy.next()) {
        	  top_fiddy.add(rs_top_fiddy.getString("product_name"));
          }
          for(String num : top_fiddy) {
        	  //out.println(num + ",");
          }
          
          
          // Result set to get log data
          rs_log = logstmt.executeQuery(
        		  "select u.state,l.product_name " +
        		  "from log l,carts c,users u " +
        		  "where u.name = c.name and c.id = l.cart_id");
          
          // Save log data into hashmap
          HashMap<String, String> log_data = new HashMap<String, String>(); 
                while(rs_log.next()) {
          	     	log_data.put(rs_log.getString("state"),rs_log.getString("product_name"));
                } 
          
          // Optimize performance by updating precomputed table
          update_cell_stmnt.executeUpdate(
          "update precomputed " +
          "set cell_sum = cell_sum + x.price " +
          "from (select u.state,l.product_name,l.price " +
          "from log l,carts c,users u " +
          "where u.name = c.name and c.id = l.cart_id) as x " + 
          "where x.product_name = precomputed.product_name and " +
          "x.state = precomputed.state;");
           
          update_state_stmnt.executeUpdate(
          "update precomputed " +
          "set state_sum = state_sum + x.total_price " +
          "from (select u.state,sum(l.price) as total_price " +
          "from log l,carts c,users u " +
          "where u.name = c.name and c.id = l.cart_id " +
          "group by u.state) as x " +
          "where x.state = precomputed.state;");
		  
          update_prod_stmnt.executeUpdate(
          "update precomputed " +
          "set product_sum = product_sum + x.total_price " +
          "from (select l.product_name ,sum(l.price) as total_price " +
          "from log l,carts c,users u " +
          "where u.name = c.name and c.id = l.cart_id " +
          "group by l.product_name) as x " +
          "where x.product_name = precomputed.product_name;"); 
          
          stmt4.executeUpdate("delete from log");
          stmt3.executeUpdate("drop table if exists precomputed;");
          stmt2.executeUpdate("create table precomputed as ( "
              +"with overall_table as("
              +"  select i.sku,u.state,sum(i.price) as amount  "
              +"  from items i"
              +"  inner join carts c on (c.id = i.id and c.purchase_date is not null)"
              +"  inner join product p on (i.sku = p.sku "+filterquery+")"
              +"  inner join users u on (c.name = u.name)"
              +"  group by i.sku,u.state"
              +"),"
              +"top_state as("
              +"  select state, sum(amount) as dollar from ("
              +"  select state, amount from overall_table"
              +"  UNION ALL"
              +"  select state as state, 0.0 as amount from state"
              +"  ) as state_union"
              +"  group by state order by dollar desc"
              +"),"
              +"top_n_state as("
              +"  select row_number() over(order by dollar desc) as state_order, state, dollar from top_state"
              +"),"
              +"top_prod as("
              +"  select sku, sum(amount) as dollar from ("
              +"  select sku, amount from overall_table"
              +"  UNION ALL"
              +"  select sku as sku, 0.0 as amount from product"
              +"  ) as product_union"
              +"  group by sku order by dollar desc limit 50"
              +"),"
              +"top_n_prod as ("
              +"  select row_number() over(order by dollar desc) as product_order, sku, dollar from top_prod"
              +")"
              +"select s.state, p.product_name, COALESCE(ot.amount, 0.0) as cell_sum, ts.dollar as state_sum, tp.dollar as product_sum"
              +"  from top_n_prod tp CROSS JOIN top_n_state ts "
              +"  LEFT OUTER JOIN overall_table ot "
              +"  ON ( tp.sku = ot.sku and ts.state = ot.state)"
              +"  inner join state s ON ts.state = s.state"
              +"  inner join product p ON (tp.sku = p.sku "+filterquery+") "
              +"  order by ts.state_order, tp.product_order);");
          rs1= stmt.executeQuery("select * from precomputed;");
          
          rs2=rs1;
          
          %>
          
          <table border="1">
            <tr>
              <%
              if(rows.equals("state")){%>
              <td><b>State</b></td>
              <%
              }
              ind=0;
              String past="";
              String present="";
              while(rs1.next()){
                present=rs1.getString("state");
                String product_name = rs1.getString("product_name");
                Double product_sum=rs1.getDouble("product_sum");
                if (ind != 0 && !past.equals(present)){
                  break;
                }
                // If new product is among the top fifty
                if(!top_fiddy.contains(product_name)) {
                out.println(product_name + " is now among the top selling products! ");
                %>
                <td bgcolor="#551A8B"><%=ind+1 %><br><%=product_name%><br><%=product_sum %></td>
                <%
                }
                else {
                %>	
                <td><%=ind+1 %><br><%=product_name%><br><%=product_sum %></td>
                <%	
                }
                ind++;
                past=present;
              }
              %>
            </tr>
            <%
            
            if(rows.equals("state")){
              int index = 1;
              rs2.beforeFirst();
              while(rs2.next()){
                %>
                <tr>
                  <%
                    statename = rs2.getString("state");
                    currentState=statename;
                    //out.println("State = " + currentState);
                    
                    double statesum= rs2.getDouble("state_sum");
                    %>
                    <td><%=index %> <br><%=statename %><br><%=statesum %></td>
                    <%             
                    
                    while(statename.equals(currentState)){
                      double amount = rs2.getDouble("cell_sum");
                      
                      //out.println("State = " + rs2.getString("product_name") + ",");
                      if(log_data.isEmpty()) {
                      %>
                        <td><%=amount%></td>
                      <%  
                      } else {
                      	if(log_data.containsKey(currentState) && log_data.get(currentState).equals(rs2.getString("product_name"))) {
                        %>
                          <td bgcolor="#FF0000"><%=amount%></td>
                        <%
                        // else cell was not updated since last refresh
                      	} else {
                        %>
                          <td><%=amount%></td>
                        <%
                      	}
                      } // end else
                      
                      if(rs2.next()){
                        statename=rs2.getString("state");
                      }else{
                        break;
                      }
                      if(!statename.equals(currentState)){
                        rs2.previous();
                      }
                    }
                    
                  %>
                </tr>
                <%
                index++;
              }//end while
            }
            %>
          </table>          
          <%        
        }//end if top-k
      }
      %>
      </table>
	  <!-- End of div for precomputed 2d table -->
      </div>
      <div class="high_cell"></div>
      <div class="cell">
      	 <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="refresh_table">
          <input type="submit" value="Refresh" onClick="refreshTable();">
        </form> 
        <!--<button onClick="refreshTable();" value="show">Refresh</button>-->
      </div>
      <div class="wide_cell"></div>
      <div class="cell">
      	 <form action="/CSE135/analytics" method="post">
          <input type="hidden" name="action" value="refresh_table">
          <input type="submit" value="Refresh" onClick="refreshTable();">
        </form>
        <!--<button onClick="refreshTable();" value="show">Refresh</button> -->
      </div>

	  <!-- End of div: grid -->
      </div>
      
      <%
    }catch(Exception e){      
      e.printStackTrace();
    }
    //close statements
    finally{
      try {
        if(rs1 != null) {
          rs1.close();
        }
        if(stmt != null) {
          stmt.close();
        }
        if(rs2 != null) {
          rs2.close();
        }
        if(stmt2 != null) {
          stmt2.close();
        }
        if(rs3 != null) {
          rs3.close();
        }
        if(stmt3 != null) {
          stmt3.close();
        }
        if(rs4 != null) {
          rs4.close();
        }
        if(stmt4 != null) {
          stmt4.close();
        }
        if(rs5 != null) {
          rs5.close();
        }
        if(stmt5 != null) {
          stmt5.close();
        }
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
    }
    %>

    

   </div>
  </body>
</html>