package com.example.hademo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class HaDemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(HaDemoApplication.class, args);
	}

}
