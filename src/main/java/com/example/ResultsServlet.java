package com.example;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/get-results")
public class ResultsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the global vote map
        ConcurrentHashMap<String, Integer> votes = (ConcurrentHashMap<String, Integer>) 
            getServletContext().getAttribute("votes");

        StringBuilder html = new StringBuilder();
        if (votes != null && !votes.isEmpty()) {
            for (String key : votes.keySet()) {
                html.append("<div class='result-bar'>")
                    .append(key).append(": ").append(votes.get(key))
                    .append(" votes</div>");
            }
        } else {
            html.append("<p>No votes yet. Be the first!</p>");
        }

        response.setContentType("text/html");
        response.getWriter().write(html.toString());
    }
}
