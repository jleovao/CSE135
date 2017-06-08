<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    import="java.util.ArrayList" pageEncoding="ISO-8859-1"%>
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
        float: left;
        max-width: 120px;
        margin: 0;
        padding: 1em;
      }
      div.tables {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }        
    </style>
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
    ResultSet rs1=null;
    ResultSet rs2=null;
    ResultSet rs3=null;
    ResultSet rs4=null;
    ResultSet rs5=null;
    ArrayList<String> catlist = new ArrayList<String>();
    String rows;
    String order;
    String action=null;
    String filter;
    String filterquery;
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
      <ul>
        <%
        if(role.equals("owner")){
          out.println("<li><a href=\"/CSE135/categories\">Categories Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/products\">Products Page(owners)</a></li>"+
                    "<li><a href=\"/CSE135/similar_products\">Similar Products</a></li>"+
                    "<li><a href=\"/CSE135/analytics\">Sales Analytics</a></li>");
        }
        %>
        <li><a href="/CSE135/browsing">Product Browsing Page</a></li>
        <li><a href="/CSE135/order">Product Order Page</a></li>
        <li><a href="/CSE135/buy">Buy Shopping Cart</a></li>
        <li><a href="/CSE135/buyOreders.jsp">Buy Orders</a></li>
      </ul>
    </div>
    <!-- choose row and column -->
<%
    try{
      Class.forName("org.postgresql.Driver");
      conn = DriverManager.getConnection(
          "jdbc:postgresql://localhost/Shopping_Application?" +
          "user=postgres&password=7124804");
      
      stmt = conn.createStatement();
      stmt2 = conn.createStatement();
      stmt3 = conn.createStatement();
      stmt4 = conn.createStatement();
      stmt5 = conn.createStatement();
      
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
              %>
              </select>
              <input type="submit" value="Filter">
            </form>
          </td>
        </tr>
      </table>
      <!-- 2-d chart that displays report -->
      
      <%
      if ((!rows.equals("") && !order.equals(""))){  
        if(order.equals("top-k")){
          if (!filterquery.equals("")){
            filterquery = "and p.category_name='"+filter+"'";
          }
          rs1=stmt.executeQuery("select p.sku,sum(i.price) as totalsum from items i,product p where p.sku=i.sku "+filterquery+" group by p.sku union (select p.sku, 0 as totalsum from product p where p.sku not in( select i.sku from items i) "+filterquery+") order by totalsum desc ");
          %>
          
          <table border="1">
            <tr>
              <%if(rows.equals("customer")){ %>
              <td><b>Customer Name</b></td>
              <%}
              if(rows.equals("state")){%>
              <td><b>State</b></td>
              <%
              }
              ind=0;
              String[] prodarray=new String[collimit];
              while(rs1.next()){
                String skuorder = rs1.getString("sku");
                rs2=stmt2.executeQuery("select p.product_name from product p where p.sku='"+skuorder+"'" );
                if(rs2.next()){
                  System.out.println(ind+" "+rs2.getString("product_name"));
                  prodarray[ind]=rs2.getString("product_name");
                }
                %>
                <td><%=prodarray[ind] %></td>
                <%
                ind++;
                }
              %>
            </tr>
            <%
            
            if(rows.equals("state")){
              rs4=stmt4.executeQuery("select u.state, sum(i.price) from carts c, users u,items i, product p where u.name=c.name and c.id=i.id and p.sku=i.sku "+filterquery+" group by u.state union (select u.state,0 from users u where u.state not in (select u.state from users u,carts c where u.name = c.name)) order by 2 desc");
              while(rs4.next()){
                %>
                <tr>
                  <%
                    String statename = rs4.getString("state");
                    %>
                    <td><%=statename %></td>
                    <%             
                    for(int i=0;i<prodarray.length;i++){
                      rs5=stmt5.executeQuery("select sum(i.price) from users u, items i, carts c, product p where c.purchase_date is not null and i.id=c.id and c.name=u.name and u.state='"+statename+"' and p.sku=i.sku and p.product_name='"+prodarray[i]+"' group by i.sku");
                      double quant = 0;
                      double price = 0;
                      double total = 0;
                      if(prodarray[i]!=null){
                        while(rs5.next()){
                          price=rs5.getDouble(1);
                          total=total +(price);
                        }
                        %>
                        <td><%=total %></td>
                        <%
                      }
                    }
                  %>
                </tr>
                <%
              }
              rs1=stmt.executeQuery("select u.state, sum(i.price) from carts c, users u,items i, product p where u.name=c.name and c.id=i.id and p.sku=i.sku "+filterquery+" group by u.state union (select u.state,0 from users u where u.state not in (select u.state from users u,carts c where u.name = c.name)) order by 2 desc ");
              if(rs1.next()){
                showrowbut= true;
              }
            }
            %>
          </table>          
          <%        
        }//end if top-k
      }
      %>
      </table>
      
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