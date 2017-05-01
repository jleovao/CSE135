<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
  <%
  String name=null;
  String role=null;
  try{
    if(session.getAttribute("name")!=null || !session.getAttribute("name").equals("")) {
      name=(String) session.getAttribute("name");
    }
    else{name=null;}
  
    if(session.getAttribute("role")!=null || !session.getAttribute("role").equals("")) {
      role=(String) session.getAttribute("role");
    }
    else{role=null;}
  }catch(Exception e){
    name=null;
    role=null;
  }
  %>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Home Page</title>
  </head>
  <body>
  	<div class="container">
      <div class ="header"><h1>Home Page</h1></div>
      <%
      if(name!=null){
        out.println("<h4>Hello, "+name+"!</h4>");
      }
      else{
        out.println("<h3>You are not logged in</h3>");
      }
      %>
      
      <div class="nav">
        <ul>
          <li><a href="/CSE135/categories">Categories Page(owners)</a></li>
          <li><a href="/CSE135/products">Products Page(owners)</a></li>
          <li><a href="/CSE135/browsing">Product Browsing Page</a></li>
          <li><a href="/CSE135/order">Product Order Page</a></li>
          <li><a href="/CSE135/cart">Shopping Cart Page</a></li>
        </ul>
      </div>

    </div>
  </body>
</html>