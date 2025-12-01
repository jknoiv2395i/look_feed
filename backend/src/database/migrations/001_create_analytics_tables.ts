import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Analytics Events Table
  await knex.schema.createTable('analytics_events', (table) => {
    table.uuid('id').primary();
    table.uuid('user_id').notNullable();
    table.string('post_id').notNullable();
    table.enum('event_type', ['POST_DETECTED', 'POST_FILTERED', 'POST_SHOWN']).notNullable();
    table.decimal('relevance_score', 3, 2).notNullable();
    table.jsonb('matched_keywords').notNullable();
    table.enum('filter_method', ['keyword', 'ai', 'hybrid']).notNullable();
    table.integer('processing_time_ms').notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

    // Indexes
    table.index('user_id');
    table.index('post_id');
    table.index('created_at');
    table.index(['user_id', 'created_at']);
  });

  // Daily Analytics Summary Table
  await knex.schema.createTable('analytics_daily_summary', (table) => {
    table.uuid('id').primary();
    table.uuid('user_id').notNullable();
    table.date('date').notNullable();
    table.integer('total_posts_viewed').notNullable().defaultTo(0);
    table.integer('total_posts_blocked').notNullable().defaultTo(0);
    table.decimal('blocking_rate', 3, 2).notNullable().defaultTo(0);
    table.integer('time_saved_minutes').notNullable().defaultTo(0);
    table.jsonb('top_keywords').nullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

    // Unique constraint
    table.unique(['user_id', 'date']);

    // Indexes
    table.index('user_id');
    table.index('date');
  });

  // Keyword Statistics Table
  await knex.schema.createTable('analytics_keyword_stats', (table) => {
    table.uuid('id').primary();
    table.uuid('user_id').notNullable();
    table.string('keyword').notNullable();
    table.integer('match_count').notNullable().defaultTo(0);
    table.decimal('effectiveness_score', 3, 2).notNullable().defaultTo(0);
    table.timestamp('last_matched').nullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

    // Unique constraint
    table.unique(['user_id', 'keyword']);

    // Indexes
    table.index('user_id');
    table.index('match_count');
  });

  // Filter Logs Table (for detailed tracking)
  await knex.schema.createTable('filter_logs', (table) => {
    table.uuid('id').primary();
    table.uuid('user_id').notNullable();
    table.string('post_id').notNullable();
    table.enum('action', ['shown', 'hidden']).notNullable();
    table.decimal('relevance_score', 3, 2).notNullable();
    table.jsonb('matched_keywords').nullable();
    table.enum('method', ['keyword', 'ai', 'hybrid']).notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

    // Indexes
    table.index('user_id');
    table.index('post_id');
    table.index('created_at');
  });

  // AI Classification Cache Table
  await knex.schema.createTable('ai_classification_cache', (table) => {
    table.uuid('id').primary();
    table.string('cache_key').notNullable().unique();
    table.string('post_id').notNullable();
    table.jsonb('keywords').notNullable();
    table.decimal('relevance_score', 3, 2).notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('expires_at').notNullable();

    // Indexes
    table.index('cache_key');
    table.index('post_id');
    table.index('expires_at');
  });

  // Rate Limit Tracking Table
  await knex.schema.createTable('rate_limit_tracking', (table) => {
    table.uuid('id').primary();
    table.uuid('user_id').notNullable();
    table.enum('tier', ['free', 'premium', 'pro']).notNullable().defaultTo('free');
    table.date('date').notNullable();
    table.integer('ai_calls_today').notNullable().defaultTo(0);
    table.integer('ai_calls_this_hour').notNullable().defaultTo(0);
    table.timestamp('last_reset').notNullable().defaultTo(knex.fn.now());
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());

    // Unique constraint
    table.unique(['user_id', 'date']);

    // Indexes
    table.index('user_id');
    table.index('date');
    table.index('tier');
  });

  // Create indexes for performance
  await knex.schema.raw(`
    CREATE INDEX idx_analytics_events_user_date 
    ON analytics_events(user_id, created_at DESC);
  `);

  await knex.schema.raw(`
    CREATE INDEX idx_analytics_events_keywords 
    ON analytics_events USING GIN(matched_keywords);
  `);
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('rate_limit_tracking');
  await knex.schema.dropTableIfExists('ai_classification_cache');
  await knex.schema.dropTableIfExists('filter_logs');
  await knex.schema.dropTableIfExists('analytics_keyword_stats');
  await knex.schema.dropTableIfExists('analytics_daily_summary');
  await knex.schema.dropTableIfExists('analytics_events');
}
