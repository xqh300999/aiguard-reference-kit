package com.elderlycare.config;

import com.elderlycare.common.Result;
import com.elderlycare.filter.JwtAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.http.HttpMethod;

import java.io.PrintWriter;
import java.util.Collections;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Autowired
    private ObjectMapper objectMapper;

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return new InMemoryUserDetailsManager(
            User.withUsername("system")
                .password(passwordEncoder().encode("system"))
                .authorities(Collections.emptyList())
                .build()
        );
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable))
            .httpBasic(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/login").permitAll()
                .requestMatchers("/api/v1/auth/register").permitAll()
                .requestMatchers("/api/web/v1/auth/register").permitAll()
                .requestMatchers("/health").permitAll()
                .requestMatchers("/favicon.ico").permitAll()
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasAuthority("ADMIN")
                .requestMatchers("/api/v1/users/**").hasAuthority("ADMIN")
                .requestMatchers("/api/v1/community/**").hasAuthority("ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/elderly/register").hasAnyAuthority("ADMIN", "WORKER", "FAMILY")
                .requestMatchers(HttpMethod.PUT, "/api/v1/elderly").hasAnyAuthority("ADMIN", "WORKER", "FAMILY")
                .requestMatchers(HttpMethod.PUT, "/api/v1/elderly/update-by-contact").hasAnyAuthority("ADMIN", "WORKER", "FAMILY")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/elderly/**").hasAnyAuthority("ADMIN", "WORKER", "FAMILY")
                .requestMatchers("/api/v1/elderly/**").hasAnyAuthority("ADMIN", "WORKER")
                .requestMatchers("/api/v1/devices/**").hasAnyAuthority("ADMIN", "WORKER")
                .requestMatchers("/api/v1/worker/**").hasAnyAuthority("ADMIN", "WORKER")
                .requestMatchers("/api/v1/family/**").hasAnyAuthority("ADMIN", "WORKER", "FAMILY")
                .anyRequest().authenticated()
            )
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setContentType("application/json;charset=UTF-8");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    PrintWriter writer = response.getWriter();
                    writer.write(objectMapper.writeValueAsString(Result.error(401, "未授权，请先登录")));
                    writer.flush();
                    writer.close();
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setContentType("application/json;charset=UTF-8");
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    PrintWriter writer = response.getWriter();
                    writer.write(objectMapper.writeValueAsString(Result.error(403, "权限不足，无法访问")));
                    writer.flush();
                    writer.close();
                })
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}