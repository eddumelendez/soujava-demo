package com.example.hademo;

import org.springframework.cloud.gcp.data.spanner.repository.SpannerRepository;

public interface UserRepository extends SpannerRepository<User, String> {

	User findByUsername(String username);
}
