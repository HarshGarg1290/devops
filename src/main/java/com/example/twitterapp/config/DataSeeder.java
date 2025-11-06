package com.example.twitterapp.config;

import com.example.twitterapp.model.Post;
import com.example.twitterapp.model.User;
import com.example.twitterapp.service.PostService;
import com.example.twitterapp.service.UserService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Conditional;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@ConditionalOnProperty(prefix = "app.seed", name = "enabled", havingValue = "true")
public class DataSeeder implements CommandLineRunner {

    private final UserService userService;
    private final PostService postService;

    public DataSeeder(UserService userService, PostService postService) {
        this.userService = userService;
        this.postService = postService;
    }

    @Override
    public void run(String... args) throws Exception {
        List<Post> existing = postService.findAll();
        if (existing != null && !existing.isEmpty()) {
            System.out.println("DataSeeder: posts already exist — skipping seeding");
            return;
        }

        System.out.println("DataSeeder: seeding demo users and posts...");

        User alice = new User("alice", "alicepass");
        User bob = new User("bob", "bobpass");
        User carol = new User("carol", "carolpass");
        User dave = new User("dave", "davepass");
        User eve = new User("eve", "evepass");

        alice = userService.save(alice);
        bob = userService.save(bob);
        carol = userService.save(carol);
        dave = userService.save(dave);
        eve = userService.save(eve);

        Post p1 = new Post(); p1.setContent("Exploring the new InsightFeed — happy to share my first post!"); p1.setUser(alice); postService.save(p1);
        Post p2 = new Post(); p2.setContent("A quick tip about productivity: batch similar tasks and focus blocks work wonders."); p2.setUser(bob); postService.save(p2);
        Post p3 = new Post(); p3.setContent("Thoughts on microservices: keep interfaces simple and document them well."); p3.setUser(carol); postService.save(p3);
        Post p4 = new Post(); p4.setContent("Weekend reading list: an intro to observability, and a deep-dive on tracing."); p4.setUser(dave); postService.save(p4);
        Post p5 = new Post(); p5.setContent("Why I switched to Tailwind for small projects: rapid iteration and consistent styles."); p5.setUser(eve); postService.save(p5);

        System.out.println("DataSeeder: seeding complete");
    }
}
