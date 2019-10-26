package com.example.hademo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloRestController {

	private final UserService userService;

	private final String message;

	public HelloRestController(UserService userService, @Value("${welcome.message}") String message) {
		this.userService = userService;
		this.message = message;
	}

	@GetMapping("/hello/{name}")
	public ResponseEntity<String> hello(@PathVariable String name) {
		User user = this.userService.findUser(name);
		if (user == null) {
			return ResponseEntity.notFound().build();
		}
		return ResponseEntity.ok(this.message + " " + name);
	}

}
