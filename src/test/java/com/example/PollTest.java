package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import java.util.concurrent.ConcurrentHashMap;

public class PollTest {
    @Test
    void testVoteCounting() {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
        map.merge("Docker", 1, Integer::sum);
        assertEquals(1, map.get("Docker"));
    }
}
