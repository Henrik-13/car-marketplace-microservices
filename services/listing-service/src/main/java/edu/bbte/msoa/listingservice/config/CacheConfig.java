package edu.bbte.msoa.listingservice.config;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;

@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager(ObjectProvider<RedisConnectionFactory> redisConnectionFactoryProvider) {
        RedisConnectionFactory redisConnectionFactory = redisConnectionFactoryProvider.getIfAvailable();

        if (redisConnectionFactory != null) {

            GenericJacksonJsonRedisSerializer serializer = GenericJacksonJsonRedisSerializer.builder()
                    .typePropertyName("@class")
                    .enableUnsafeDefaultTyping()
                    .build();

            RedisCacheConfiguration cacheConfig = RedisCacheConfiguration.defaultCacheConfig()
                    .entryTtl(Duration.ofMinutes(60))
                    .disableCachingNullValues()
                    .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(serializer));

            return RedisCacheManager.builder(redisConnectionFactory)
                    .cacheDefaults(cacheConfig)
                    .build();
        }

        return new ConcurrentMapCacheManager();
    }
}
