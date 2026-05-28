using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using StyleAI.Domain.Entities;

namespace StyleAI.Infrastructure.Persistence.Configurations;

public class ClickTrackingConfiguration : IEntityTypeConfiguration<ClickTracking>
{
    public void Configure(EntityTypeBuilder<ClickTracking> builder)
    {
        builder.ToTable("ClickTrackings", t => t.HasCheckConstraint(
            "CK_ClickTrackings_SavedAmount_NonNegative",
            "\"SavedAmount\" >= 0"));

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .UseIdentityAlwaysColumn();

        builder.Property(c => c.AffiliateTrackingId)
            .IsRequired();

        builder.HasIndex(c => c.AffiliateTrackingId)
            .IsUnique();

        builder.Property(c => c.TargetMerchant)
            .IsRequired()
            .HasMaxLength(64);

        builder.Property(c => c.TargetProductUrl)
            .HasMaxLength(1024);

        builder.Property(c => c.TargetProductImageUrl)
            .HasMaxLength(512);

        builder.Property(c => c.OriginalPrice)
            .HasPrecision(18, 2);

        builder.Property(c => c.DupePrice)
            .HasPrecision(18, 2);

        builder.Property(c => c.SavedAmount)
            .HasPrecision(18, 2);

        builder.Property(c => c.Currency)
            .IsRequired()
            .HasMaxLength(3);

        builder.Property(c => c.IsConverted)
            .HasDefaultValue(false);

        builder.Property(c => c.CommissionAmount)
            .HasPrecision(18, 2);

        builder.Property(c => c.ClickedAt)
            .IsRequired();

        builder.HasIndex(c => new { c.UserId, c.ClickedAt });

        builder.HasIndex(c => c.SearchLogId);

        builder.HasIndex(c => new { c.IsConverted, c.ClickedAt });
    }
}
