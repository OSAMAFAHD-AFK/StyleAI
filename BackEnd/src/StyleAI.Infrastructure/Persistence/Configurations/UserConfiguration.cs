using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using StyleAI.Domain.Entities;

namespace StyleAI.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users", t => t.HasCheckConstraint(
            "CK_Users_TotalSavings_NonNegative",
            "\"TotalSavings\" >= 0"));

        builder.HasKey(u => u.Id);

        builder.Property(u => u.DeviceToken)
            .IsRequired()
            .HasMaxLength(128);

        builder.HasIndex(u => u.DeviceToken)
            .IsUnique();

        builder.Property(u => u.Email)
            .HasMaxLength(320);

        builder.Property(u => u.PreferredCountry)
            .IsRequired()
            .HasMaxLength(2);

        builder.Property(u => u.PreferredCurrency)
            .IsRequired()
            .HasMaxLength(3);

        builder.Property(u => u.TotalSavings)
            .HasPrecision(18, 2);

        builder.Property(u => u.Status)
            .HasConversion<string>()
            .HasMaxLength(32);

        builder.Property(u => u.CreatedAt)
            .IsRequired();

        builder.Property(u => u.UpdatedAt)
            .IsRequired();

        builder.HasMany(u => u.SearchLogs)
            .WithOne(s => s.User)
            .HasForeignKey(s => s.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(u => u.ClickTrackings)
            .WithOne(c => c.User)
            .HasForeignKey(c => c.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
