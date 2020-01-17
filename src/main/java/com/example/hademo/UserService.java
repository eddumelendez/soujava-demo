package com.example.hademo;

import java.util.stream.Stream;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class UserService {

	private Logger logger = LoggerFactory.getLogger(UserService.class);

	private final UserRepository repository;

	public UserService(UserRepository repository) {
		this.repository = repository;
	}

	@PostConstruct
	public void load() {
		this.repository.deleteAll();
		Stream.of("otavio", "eddu")
				.map(username -> {
					User user = new User();
					user.setUsername(username);
					return user;
				})
				.forEach(this.repository::save);
	}

	@Cacheable(cacheNames = "users")
	public User findUser(String name) {
		logger.info("look for " + name);
		return this.repository.findByUsername(name);
	}
}
