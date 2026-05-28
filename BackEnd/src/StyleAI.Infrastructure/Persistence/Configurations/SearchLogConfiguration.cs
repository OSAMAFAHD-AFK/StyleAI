using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using StyleAI.Domain.Entities;

namespace StyleAI.Infrastructure.Persistence.Configurations;

public class SearchLogConfiguration : IEntityTypeConfiguration<SearchLog>
{
    public void Configure(EntityTypeBuilder<SearchLog> builder)
    {
        builder.ToTable("SearchLogs");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.Id)
            .UseIdentityAlwaysColumn();

        builder.Property(s => s.Category)
            .IsRequired()
            .HasMaxLength(64);

        builder.Property(s => s.Color)
            .IsRequired()
            .HasMaxLength(64);

        builder.Property(s => s.StyleAesthetic)
            .IsRequired()
            .HasMaxLength(128);

        builder.Property(s => s.DetectedBrand)
            .HasMaxLength(128);

        builder.Property(s => s.Gender)
            .HasConversion<string>()
            .HasMaxLength(16);

        builder.Property(s => s.CountryCode)
            .IsRequired()
            .HasMaxLength(2);

        builder.Property(s => s.CroppedImageUrl)
            .HasMaxLength(512);

        builder.Property(s => s.EstimatedReferencePrice)
            .HasPrecision(18, 2);

        builder.Property(s => s.ReferenceCurrency)
            .HasMaxLength(3);

        builder.Property(s => s.AiModelVersion)
            .HasMaxLength(64);

        builder.Property(s => s.SearchedAt)
            .IsRequired();

        builder.HasIndex(s => new { s.UserId, s.SearchedAt });

        builder.HasIndex(s => new { s.CountryCode, s.SearchedAt });

        builder.HasIndex(s => new { s.Category, s.SearchedAt });

        builder.HasMany(s => s.ClickTrackings)
            .WithOne(c => c.SearchLog)
            .HasForeignKey(c => c.SearchLogId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
